import SwiftUI
import Alamofire
import UIKit

struct ContentView: View {
    @State private var scriptText = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Welcome to PlotBot!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.top, 50)
                
                TypewriterView(text: "An AI powered movie script generator.", speed: 0.1)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 50)
                
                Button(action: generateScript) {
                    Text("Generate Movie Script")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(isLoading ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(2)
                }
                
                ScrollView {
                    Text(scriptText)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    UIPasteboard.general.string = scriptText
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.footnote)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    private func generateScript() {
        isLoading = true
        
        let prompts = [
            "Could you give me 10 ideas for a feature film?",
            "Choose one of the 10 that you think is the best. Could you give me 10 ideas for that concept?",
            "Which of these do you think would be most successful in the marketplace?",
            "Okay, please ask me ten questions that would help clarify our needs for this project.",
            "Please provide the best possible answers to these questions",
            "Based on these answers please provide a compelling logline and outline for the movie along with a synopsis, structure, and detailed character descriptions making sure this movie feels completely original and incorporates all of the elements that would make for a great film.",
            "Great now please please write the first entire scene of this movie including dialogue in proper movie script format.",
            "Okay thanks, now please assume the persona of a major successful Hollywood producer who is extremely critical and generally pessimistic and critique our movie overall and scene 1.",
            "Okay, based upon the feedback please add those elements and suggestions and rewrite scene 1 in movie script format.",
            "Okay now take on the persona of a successful Hollywood writer that has won academy awards for best screenplay who is asked to read the above scene and give feedback and criticism.",
            "Okay now please rewrite scene 1 based upon this feedback and suggestions and print out below the final logline followed by the final updated version of scene 1 in movie script format."
        ]
        
        OpenAIApiClient().generateScript(prompts: prompts) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let script):
                    scriptText = script
                case .failure(let error):
                    scriptText = "An error occurred: \(error.localizedDescription)"
                }
            }
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    struct TypewriterView: View {
        @State private var displayText = ""
        let text: String
        let speed: Double
        
        var body: some View {
            Text(displayText)
                .onAppear(perform: typeText)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
        }
        private func typeText() {
            var currentCharacterIndex = 0
            Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
                if currentCharacterIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: currentCharacterIndex)
                    displayText.append(text[index])
                    currentCharacterIndex += 1
                } else {
                    timer.invalidate()
                    resetText()
                }
            }
        }
        
        private func resetText() {
            displayText = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                typeText()
            }
        }
    }
}

