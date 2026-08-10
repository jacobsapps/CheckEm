//
//  AccountView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import CachedAsyncImage
import CoreImage.CIFilterBuiltins
import LocalAuthentication
import SwiftUI
import TipKit

struct AccountView: View {
    
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 36
    @State private var exportError = ""
    @State private var secretPresentation: SecretPresentation?
    @State private var showCopied: Bool = false
    @State private var showExportError: Bool = false
    let account: Account
    let onDelete: () -> Void
    
    var body: some View {
        Section(account.name) {
//        Section(String(account.name.split(separator: "—").first!)) {
            Button(action: {
                copyCode()
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    icon
                    code
                    countdown
                }
                .contentShape(Rectangle())
            })
            .contextMenu {
                Button("Copy Code", systemImage: "doc.on.doc", action: copyCode)
                    .disabled(account.code == nil)

                Section("Share Secret") {
                    Button("As Text", systemImage: "square.and.arrow.up") {
                        authenticateAndShareSecret(as: .shareSheet)
                    }

                    Button("Via QR Code", systemImage: "qrcode") {
                        authenticateAndShareSecret(as: .qrCode)
                    }
                }

                Divider()

                Button(role: .destructive, action: onDelete) {
                    Label("Delete Account", systemImage: "trash")
                }
            }
            .sheet(item: $secretPresentation, onDismiss: {
                secretPresentation = nil
            }) {
                switch $0.mode {
                case .shareSheet:
                    ShareSheet(item: $0.uri)
                case .qrCode:
                    SecretQRCodeView(accountName: account.name, uri: $0.uri)
                }
            }
            .alert("Unable to Share Secret", isPresented: $showExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportError)
            }
        }
    }
    
    private var icon: some View {
        CachedAsyncImage(url: FavIcon(issuer: account.issuer).url, content: {
            $0
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        }, placeholder: {
            Text(String(account.issuer.first?.uppercased() ?? account.name.first?.uppercased() ?? ""))
                .font(.largeTitle)
                .monospaced()
        })
        .frame(width: iconSize, height: iconSize, alignment: .center)
    }
    
    private var code: some View {
        ViewThatFits {
            HStack(alignment: .center, spacing: 16) {
                codeText
            }
            VStack(alignment: .leading, spacing: 4) {
                codeText
            }
        }
    }
    
//#error("When the view first appears, it switches between code -> ----- -> code, even though it's refreshed - is the code being erased somewhere?")
    @ViewBuilder
    private var codeText: some View {
        Text(account.code ?? "------")
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        if showCopied {
            Text("Copied")
                .font(.caption)
                .foregroundStyle(Color.primary)
        }
    }
    
    private var countdown: some View {
        CountdownView(countdown: account.countdown)
            .id(account.name)
    }
    
    private func copyCode() {
        if let code = account.code {
            UIPasteboard.general.string = code
            withAnimation {
                showCopied = true
            }
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation {
                    showCopied = false
                }
            }
        }
    }

    private func authenticateAndShareSecret(as mode: SecretPresentation.Mode) {
        Task { @MainActor in
            do {
                let context = LAContext()
                guard try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Share your 2FA secret"
                ) else { return }

                guard let record = try KeychainManager.shared.fetchAccount(named: account.name),
                      let url = URL(string: record),
                      url.scheme == "otpauth",
                      url.host == "totp" else {
                    throw KeychainManager.KeychainManagerError.accountNotFound
                }
                secretPresentation = SecretPresentation(mode: mode, uri: record)
            } catch {
                guard !error.isAuthenticationCancellation else { return }
                exportError = error.localizedDescription
                showExportError = true
            }
        }
    }
}

private struct SecretPresentation: Identifiable {

    enum Mode {
        case shareSheet
        case qrCode
    }

    let id = UUID()
    let mode: Mode
    let uri: String
}

private struct ShareSheet: UIViewControllerRepresentable {

    let item: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [item], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

private struct SecretQRCodeView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    let accountName: String
    let uri: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let qrCode = qrCode {
                    Image(uiImage: qrCode)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 16))
                        .accessibilityLabel("2FA setup QR code for \(accountName)")
                }

                Text("Scan with another device")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle(accountName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .overlay {
            if scenePhase != .active {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            if newScenePhase != .active {
                dismiss()
            }
        }
    }

    private var qrCode: UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(uri.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let image = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: image)
    }
}

extension Error {
    var isAuthenticationCancellation: Bool {
        let code = (self as NSError).code
        return code == LAError.Code.userCancel.rawValue
            || code == LAError.Code.systemCancel.rawValue
            || code == LAError.Code.appCancel.rawValue
    }
}

struct CountdownView: View {
    
    @ScaledMetric(relativeTo: .caption) var tickSize: CGFloat = 3
    @ScaledMetric(relativeTo: .body) var tickOffset: CGFloat = 20
    @ScaledMetric(relativeTo: .body) var countdownTextWidth: CGFloat = 28
    
    let countdown: Int?
    
    var body: some View {
        ZStack {
            clockFace
            number
        }
        .animation(.bouncy, value: countdown)
        .padding(.trailing, tickOffset / 2.0)
    }
    
    @ViewBuilder
    private var number: some View {
        if let countdown {
            Text("\(countdown)")
                .font(.body)
                .fontWeight(.medium)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.primary)
                .transition(.opacity)
                .frame(width: countdownTextWidth, alignment: .center)
        }
    }
    
    @ViewBuilder
    private var clockFace: some View {
        if let countdown {
            ForEach(0..<30) {
                let angle = Angle.degrees(Double($0 * 12))
                Circle()
                    .frame(width: tickSize)
                    .foregroundColor(countdown <= $0 ? .clear : .green)
                    .offset(x: -tickOffset * cos(CGFloat(angle.radians)),
                            y: tickOffset * sin(CGFloat(angle.radians)))
            }
            .transition(.opacity)
            .rotationEffect(.degrees(90))
        }
    }
}
