//
//  ViewController.swift
//  SpeechRecognizorApp
//
//  Created by GLB-285-PC on 15/05/18.
//  Copyright © 2018 Globussoft. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController,SFSpeechRecognizerDelegate,SFSpeechRecognitionTaskDelegate {

    @IBOutlet weak var answerLabel: UITextView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var isRecording = false
    //This will process the audio stream. It will give updates when the mic is receiving audio.
    let audioEngine = AVAudioEngine()
    //This will do the actual speech recognition. It can fail to recognize speech and return nil, so it’s best to make it an optional.
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    //By default, the speech recognizer will detect the devices locale and in response recognize the language appropriate to that geographical location. The default language can also be set by passing in a locale argument and identifier.
//    let speechRecognizera: SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    //This allocates speech as the user speaks in real-time and controls the buffering. If the audio was pre-recorded and stored in memory you would use a SFSpeechURLRecognitionRequest instead.
    let request = SFSpeechAudioBufferRecognitionRequest()
    //This will be used to manage, cancel, or stop the current recognition task.
    var recognitionTask:SFSpeechRecognitionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      self.requestSpeechAuthorization()
        
    }
    
    //set up for the audio engine and speech recognizer
    func recordAndRecognizeSpeech()  {
        //Nodes have input and output busses, which can be thought of as connection points. For example, an effect typically has one input bus and one output bus. A mixer typically has multiple input busses and one output bus
       

         let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus:0)
        node.installTap(onBus:0,bufferSize:1024,format:recordingFormat){ buffer,_ in
           self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            return print("here is audioEngine error",error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
                print("recognizer not supported to the current locale")
                return
            }
            if !myRecognizer.isAvailable {
                 print("recognizer not available")
                return
            }
        
//        recognitionTask = speechRecognizer?.recognitionTask(with: request, delegate: self)
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
        
            if result != nil { // check to see if result is empty (i.e. no speech found)
                if let result = result {
                    
                    let bestString = result.bestTranscription.formattedString
                    self.answerLabel.text = bestString
                    print("Response is",bestString)

                    var lastString: String = ""
                    // last string as an argument that will be checked in uicolor
                    for segment in result.bestTranscription.segments {
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = bestString.substring(from: indexTo)
                    }
                    self.checkForColoursSaid(resultString: lastString)
                    
                } else if let error = error {
                    self.showAlert(title: "", message: "There has been a speech recognition error")
                    print(error)
                }
            }else{
                print("result nil")
            }
            
        })
}
    
    //MARK: show alert
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        DispatchQueue.main.async { [unowned self] in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: handler))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    func checkForColoursSaid(resultString:String){
        switch resultString {
        case "red":
            colorView.backgroundColor = UIColor.red
        case "orange":
            colorView.backgroundColor = UIColor.orange
        case "white":
            colorView.backgroundColor = UIColor.white
        case "blue":
            colorView.backgroundColor = UIColor.blue
        case "yellow":
            colorView.backgroundColor = UIColor.yellow
        case "green":
            colorView.backgroundColor = UIColor.green
        case "brown":
            colorView.backgroundColor = UIColor.brown
        case "black":
            colorView.backgroundColor = UIColor.black
        case "gray":
            colorView.backgroundColor = UIColor.gray
        case "purple":
            colorView.backgroundColor = UIColor.purple
        default:
            break
        }
    }
    
//
    @IBAction func startButtonAction(_ sender: Any) {
        print("here")
        if isRecording {
            request.endAudio() // Added line to mark end of recording
            audioEngine.stop()
//           let node = audioEngine.inputNode
//            node.removeTap(onBus: 0)
         
            recognitionTask?.cancel()
            startButton.setTitle("Start", for: .normal)
            isRecording = false
            startButton.backgroundColor = UIColor.gray
            
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionTask = nil
            }
            
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.setTitle("Stop", for: .normal)
            startButton.backgroundColor = UIColor.red
        }
       
}

func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authstatus in
            OperationQueue.main.addOperation {
                switch authstatus {
                case .authorized:
                    self.startButton.isEnabled = true
                print("Authorized");
               case .denied:
                       self.startButton.isEnabled = false
                       self.answerLabel.text = "Üser denied äccess to speech recognization"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.answerLabel.text = "speech recognization restricted in the device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.answerLabel.text = "speech recognizationnot yet authorized"
            }
        }
    }
}
    
    
    // MARK: Speech Recognizer Delegate (only called when using the advanced recognition technique)
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("SpeechRecognizer available: \(available)")
    }
    
    
    // MARK: Speech Recognizer Task Delegate
    
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }
    
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskFinishedReadingAudio")
    }
    
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskWasCancelled")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("didFinishSuccessfully")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didRecord audioPCMBuffer: AVAudioPCMBuffer) {
        print("didRecord")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("didFinishRecognition")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

