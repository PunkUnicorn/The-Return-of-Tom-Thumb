using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using NAudio.Lame;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace TomThumbPremiumAudioBook
{
    public class Program
    {
        private static string key;
        private static string voiceCode;
        private static string inputSsmlTemplate;
        private static string outputFolder;
        private static string inputContentFile;

        static async Task<int> Main(string[] args)
        {
            try
            {
                try { key = args[0]; }
                catch { Console.Error.WriteLine("Need the first parameter to be the key, the second to be the input SSML file, third the output folder"); return 1; }

                if (Path.GetExtension(key).Length > 0)
                    key = File.ReadAllText(key);

                try { inputSsmlTemplate = args[1]; }
                catch { Console.Error.WriteLine("Need the second parameter to be the input SSML filename, third the output folder"); return 1; }

                try { outputFolder = args[2]; }
                catch { Console.Error.WriteLine("Need the third parameter to be the output folder"); return 1; }

                try { inputContentFile = args[3]; }
                catch { Console.Error.WriteLine("ssml template input file error (fourth parameter)"); return 1; }

                if (args.Length >= 5) voiceCode = args[4];
                else voiceCode = "en-GB-LibbyNeural";

                Console.WriteLine($"Started at {DateTime.Now}");

                var lines = File.ReadAllLines(inputContentFile)
                    .Select(s => s.Replace("<sub>", "").Replace("</sub>", ""))
                    .Where(w => !w.StartsWith("!["))
                    .ToArray();

                var taken = 0;
                const int batchsize = 50;
                var batch = lines.Skip(taken).Take(batchsize);
                taken += batchsize;
                var index = 0;
                var listOfMp3s = new List<string>();
                while (batch.Any())
                {
                    var model = new Dictionary<string, object>() { { "voice", voiceCode }, { "content", string.Join('\n', batch) } };

                    var result = await SynthesizeAudioAsync(key, "uksouth", ++index, model, inputSsmlTemplate, outputFolder);
                    listOfMp3s.Add(result);

                    batch = lines.Skip(taken).Take(batchsize);
                    taken += batchsize;
                }

                // Combine the mp3s
                var files = Directory.GetFiles(outputFolder, "*.mp3").OrderBy(ob => int.Parse(Path.GetFileNameWithoutExtension(ob))).ToArray();

                Concatenate(Path.Combine(outputFolder, "The-Return-of-Tom-Thumb-Autoread.mp3"), files);
                return 0;
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e.Message);
                return 1;
            }
            finally
            {
                Console.WriteLine($"Finished at {DateTime.Now}");
            }
        }

        public static void Concatenate(string outfile, params string[] mp3filenames)
        {
            if (File.Exists(outfile))
                File.Delete(outfile);

            LameMP3FileWriter writer = null;
            foreach (string filename in mp3filenames)
                using (var reader = new Mp3FileReader(filename))
                {
                    if (writer == null)
                        writer = new LameMP3FileWriter(outfile, reader.WaveFormat, LAMEPreset.VBR_90);
                    reader.CopyTo(writer);
                }

            if (writer != null)
                writer.Dispose();

        }

        static async Task<string> SynthesizeAudioAsync(string key, string region, int index, IDictionary<string, object> model, string inputSsml, string outputFolder)
        {
            var config = SpeechConfig.FromSubscription(key, region);
            var fn = index.ToString().PadLeft(3, '0');
            var wavFilename = Path.Combine(outputFolder, Path.ChangeExtension(fn, "wav"));
            if (!Directory.Exists(outputFolder))
                Directory.CreateDirectory(outputFolder);

            SpeechSynthesisResult result;
            var bytes = new byte[] { };
            using (var audioConfig = AudioConfig.FromWavFileOutput(wavFilename))
            using (var synthesizer = new SpeechSynthesizer(config, audioConfig))
            {
                var ssml = File.ReadAllText(inputSsml);
                var template = Scriban.Template.Parse(ssml);
                var content = template.Render(model);

                if (string.IsNullOrWhiteSpace(content.Trim('\n')))
                    return "";


                result = await synthesizer.SpeakSsmlAsync(content);
                await File.WriteAllTextAsync(Path.Combine(outputFolder, Path.ChangeExtension(fn, "txt")), content);
            }

            var mp3Filename = Path.Combine(outputFolder, Path.ChangeExtension(fn, "mp3"));
            if (result.AudioData.Any())
                using (var ms = new MemoryStream(result.AudioData))
                {
                    ConvertWavStreamToMp3File(ms, mp3Filename);
                    File.Delete(wavFilename);
                }           

            return mp3Filename;
        }


        /// https://stackoverflow.com/questions/16021302/c-sharp-save-text-to-speech-to-mp3-file 
        public static void ConvertWavStreamToMp3File(MemoryStream ms, string savetofilename)
        {
            //rewind to beginning of stream
            ms.Seek(0, SeekOrigin.Begin);

            using (var retMs = new MemoryStream())
            using (var rdr = new WaveFileReader(ms))
            using (var wtr = new LameMP3FileWriter(savetofilename, rdr.WaveFormat, LAMEPreset.VBR_90))
            {
                rdr.CopyTo(wtr);
            }
        }
    }
}
