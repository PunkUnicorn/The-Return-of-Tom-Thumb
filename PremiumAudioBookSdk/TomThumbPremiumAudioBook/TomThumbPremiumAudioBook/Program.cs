using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using NAudio.Lame;
using NAudio.Wave;
using System;
using System.IO;
using System.Threading.Tasks;

namespace TomThumbPremiumAudioBook
{
    public class Program
    {
        private static string key;
        private static string region;
        private static string inputSsml;
        private static string outputFilename;

        static async Task<int> Main(string[] args)
        {
            try
            { 
                try { key = args[0]; } 
                catch { Console.Error.WriteLine("Need the first parameter to be the key, the second to be the input SSML file, third the output filename(, fourth parameter is the optional region)"); return 1; }

                try { inputSsml = args[1]; }
                catch { Console.Error.WriteLine("Need the second parameter to be the input SSML filename, third the output filename(, fourth parameter is the optional region)"); return 1; }

                try { outputFilename = args[2]; }
                catch { Console.Error.WriteLine("Need the third parameter to be the output filename(, fourth parameter is the optional region)"); return 1; }

                
                if (args.Length >= 4) region = args[3];
                else region = "uksouth";

                await SynthesizeAudioAsync(key, region, inputSsml, outputFilename);

                return 0;
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e.Message);
                return 1;
            }
        }

        static async Task SynthesizeAudioAsync(string key, string region, string inputSsml, string outputFilename)
        {
            var config = SpeechConfig.FromSubscription(key, region);
            using (var audioConfig = AudioConfig.FromWavFileOutput(Path.ChangeExtension(outputFilename,"wav")))
            using (var synthesizer = new SpeechSynthesizer(config, audioConfig))
            {
                //await synthesizer.SpeakTextAsync("A simple test to write to a file.");

                var ssml = File.ReadAllText(inputSsml);
                var result = await synthesizer.SpeakSsmlAsync(ssml);
                //using (var stream = AudioDataStream.FromResult(result))
                using (var ms = new MemoryStream(result.AudioData))
                    ConvertWavStreamToMp3File(ms, Path.ChangeExtension(outputFilename, "mp3"));
                //await stream.SaveToWaveFileAsync("path/to/write/file.wav");
            }
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

        //static async Task SynthesizeAudioAsync()
        //{
        //    var config = SpeechConfig.FromSubscription("YourSubscriptionKey", "YourServiceRegion");
        //    using var audioConfig = AudioConfig.FromWavFileOutput("path/to/write/file.wav");
        //}
    }
}
