// Created by User on 2023/10/20.
import SwiftUI

struct BrowserTabBar: View {
    @ObservedObject var webVM: WebViewModel
    @ObservedObject var drawVM: DrawingViewModel
    @FocusState var urlFieldIsFocused: Bool
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        HStack(spacing: 10) {
            Button { webVM.goBack() }
                label: { Image(systemName: "chevron.left") }
                .disabled(!webVM.canGoBack)
                .foregroundColor(webVM.canGoBack ? .primary : .gray)

            Button { webVM.goForward() }
                label: { Image(systemName: "chevron.right") }
                .disabled(!webVM.canGoForward)
                .foregroundColor(webVM.canGoForward ? .primary : .gray)
            Spacer()
            Spacer()
            Spacer()
            Group {
                if drawVM.isEditingURL {
                    TextField("browsertabbar.enter_url", text: $drawVM.urlString)
                        .focused($urlFieldIsFocused)
                        .onAppear {urlFieldIsFocused = true}
                        .onSubmit {
                            var entered = drawVM.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                            // If fully qualified URL with scheme, use it directly
                            if let url = URL(string: entered), url.scheme != nil {
                                webVM.load(url)
                            } else if entered.contains(".") {
                                // Treat as domain and add https:
                                entered = "https://" + entered
                                if let url = URL(string: entered) {
                                    webVM.load(url)
                                }
                            } else {
                                // Treat as search query
                                let query = entered.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "https://www.google.com/search?q=" + query) {
                                    webVM.load(url)
                                }
                            }
                            drawVM.isEditingURL = false
                        }
                        .onChange(of: urlFieldIsFocused) { _, newValue in
                            if !newValue {
                                drawVM.isEditingURL = false
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.6, minHeight: 36)
                        .keyboardType(.URL)
                        .submitLabel(.go)
                        .autocapitalization(.none)
                } else {
                    Text(webVM.pageTitle.isEmpty ? webVM.url.absoluteString : webVM.pageTitle)
                        .font(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.6, minHeight: 36)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            drawVM.urlString = webVM.url.absoluteString
                            drawVM.isEditingURL = true
                        }
                }
            }
            Spacer()
            Spacer()
            Button { webVM.reload() }
                label: { Image(systemName: "arrow.clockwise") }
                .foregroundColor(.primary)
            Button(action: {
                activeSheet = .settings
            }) {
                Image(systemName: "gearshape.fill")
                    .rotationEffect(.degrees(90)) // 縦の三点リーダ
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .frame(height: 30)
    }
}
