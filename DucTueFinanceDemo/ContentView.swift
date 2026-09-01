import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("ductuefinance.profileName") private var profileName = "Đào Tuấn Minh"
    @AppStorage("ductuefinance.accountNumber") private var accountNumber = "0123456789"

    @State private var selectedTab = 0
    @State private var showPIN = false
    @State private var isLoggedIn = false
    @State private var showBalance = false
    @State private var showQR = false
    @State private var showTransfer = false
    @State private var showProfileEditor = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()

            Group {
                switch selectedTab {
                case 0:
                    HomeScreen(
                        profileName: profileName,
                        accountNumber: accountNumber,
                        isLoggedIn: isLoggedIn,
                        showBalance: $showBalance,
                        onLogin: { showPIN = true },
                        onQR: { showQR = true },
                        onTransfer: { showTransfer = true },
                        onEditProfile: { showProfileEditor = true }
                    )
                case 1:
                    AccountsScreen(accountNumber: accountNumber)
                case 2:
                    TransactionsScreen(onTransfer: { showTransfer = true }, onQR: { showQR = true })
                case 3:
                    CardsScreen()
                default:
                    MoreScreen()
                }
            }
            .padding(.bottom, 82)

            MainTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showPIN) {
            PINScreen { success in
                if success {
                    isLoggedIn = true
                    showPIN = false
                }
            } onClose: {
                showPIN = false
            }
        }
        .fullScreenCover(isPresented: $showTransfer) {
            TransferScreen(onClose: { showTransfer = false })
        }
        .sheet(isPresented: $showQR) {
            QRDemoView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorSheet(
                profileName: $profileName,
                accountNumber: $accountNumber
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Shared theme

private struct AppBackground: View {
    var body: some View {
        Color(red: 0.965, green: 0.975, blue: 0.985)
            .ignoresSafeArea()
    }
}

private enum DTColor {
    static let blue = Color(red: 0.04, green: 0.43, blue: 0.95)
    static let deepBlue = Color(red: 0.02, green: 0.27, blue: 0.78)
    static let ink = Color(red: 0.04, green: 0.07, blue: 0.13)
    static let muted = Color(red: 0.58, green: 0.61, blue: 0.67)
    static let bg = Color(red: 0.965, green: 0.975, blue: 0.985)
}

private struct DemoBadge: View {
    var body: some View {
        Text("MÔ PHỎNG")
            .font(.system(size: 9, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(DTColor.blue)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(DTColor.blue.opacity(0.08), in: Capsule())
    }
}

// MARK: - Home

private struct HomeScreen: View {
    let profileName: String
    let accountNumber: String
    let isLoggedIn: Bool
    @Binding var showBalance: Bool
    let onLogin: () -> Void
    let onQR: () -> Void
    let onTransfer: () -> Void
    let onEditProfile: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HomeHeader(
                    profileName: profileName,
                    onEditProfile: onEditProfile
                )
                AccountHero(
                    accountNumber: accountNumber,
                    isLoggedIn: isLoggedIn,
                    showBalance: $showBalance,
                    onLogin: onLogin,
                    onQR: onQR
                )
                PromoBanner()
                SpendingCard()
                FavoritesCard(onTransfer: onTransfer)
                RecentTransactionsCard()
                Color.clear.frame(height: 28)
            }
        }
        .background(DTColor.bg)
    }
}

private struct HomeHeader: View {
    let profileName: String
    let onEditProfile: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onEditProfile) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 58, height: 58)
                        Image(systemName: "person.fill")
                            .font(.system(size: 29))
                            .foregroundStyle(Color.gray.opacity(0.55))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Xin chào,")
                            .font(.system(size: 17))
                            .foregroundStyle(DTColor.ink)
                        Text(profileName.isEmpty ? "Chủ tài khoản!" : "\(profileName)!")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(DTColor.ink)
                            .lineLimit(1)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(DTColor.ink)
                .frame(width: 42, height: 42)

            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DTColor.ink)
                    .frame(width: 42, height: 42)
                Circle()
                    .fill(DTColor.blue)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .offset(x: -3, y: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(.white)
    }
}

private struct AccountHero: View {
    let accountNumber: String
    let isLoggedIn: Bool
    @Binding var showBalance: Bool
    let onLogin: () -> Void
    let onQR: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.50, blue: 0.98), Color(red: 0.02, green: 0.33, blue: 0.80)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 310, height: 310)
                .offset(x: 190, y: 32)

            RoundedRectangle(cornerRadius: 110)
                .stroke(Color.white.opacity(0.09), lineWidth: 2)
                .frame(width: 440, height: 170)
                .rotationEffect(.degrees(13))
                .offset(x: 195, y: 48)

            VStack(alignment: .leading, spacing: 17) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Tài khoản")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(Color.black.opacity(0.22), in: Capsule())

                    if !accountNumber.isEmpty {
                        Text("STK: \(accountNumber)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Số dư khả dụng")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.92))

                    HStack(spacing: 12) {
                        Text(showBalance ? "340 đ" : "••••••••đ")
                            .font(.system(size: 31, weight: .semibold))
                            .foregroundStyle(.white)

                        Button {
                            showBalance.toggle()
                        } label: {
                            Image(systemName: showBalance ? "eye.slash" : "eye")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.60))
                        }
                    }
                }

                HStack(spacing: 14) {
                    OutlineAction(title: isLoggedIn ? "Đã đăng nhập" : "Đăng nhập", action: onLogin)
                    OutlineAction(title: "Quét QR", action: onQR)
                }
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 42)
        }
        .frame(height: 470)
        .clipped()
    }
}

private struct PromoBanner: View {
    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Sở hữu ngay")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(DTColor.blue)
                Text("Tài khoản Siêu Lợi Suất\nđến 8%/năm")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(DTColor.ink)
                HStack(spacing: 5) {
                    Circle().fill(Color.gray.opacity(0.25)).frame(width: 7, height: 7)
                    Circle().fill(Color.gray.opacity(0.25)).frame(width: 7, height: 7)
                    Capsule().fill(DTColor.blue).frame(width: 34, height: 7)
                }
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(colors: [Color.blue.opacity(0.10), Color.blue.opacity(0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 184, height: 168)
                Image(systemName: "chart.bar.xaxis.ascending")
                    .font(.system(size: 68, weight: .bold))
                    .foregroundStyle(DTColor.blue)
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 47))
                    .foregroundStyle(.orange)
                    .offset(x: 56, y: 53)
            }
        }
        .padding(.leading, 34)
        .padding(.trailing, 12)
        .frame(height: 214)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 34)
        .padding(.top, 32)
    }
}

private struct SpendingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Cập nhật chi tiêu")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 19, weight: .semibold))
            }
            Capsule()
                .fill(Color.blue.opacity(0.12))
                .frame(height: 10)
        }
        .padding(30)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 34)
        .padding(.top, 28)
    }
}

private struct FavoritesCard: View {
    let onTransfer: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack {
                Text("Tính năng yêu thích")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                    .foregroundStyle(.gray)
            }

            HStack(spacing: 10) {
                FeatureItem(icon: "flag.fill", title: "Tiết kiệm\nmục tiêu", action: {})
                FeatureItem(icon: "bolt.fill", title: "Thanh toán\ntiền điện", action: onTransfer)
                FeatureItem(icon: "water.waves", title: "Thanh toán\ntiền nước", action: onTransfer)
            }
        }
        .padding(30)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 34)
        .padding(.top, 28)
    }
}

private struct RecentTransactionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Giao dịch gần đây")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 22, weight: .medium))
            }
            TransactionRow(icon: "cart.fill", title: "Mua sắm", subtitle: "Hôm nay", amount: "-250.000đ")
            Divider().padding(.leading, 54)
            TransactionRow(icon: "arrow.down.circle.fill", title: "Tiền vào", subtitle: "Hôm qua", amount: "+1.200.000đ")
        }
        .padding(30)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 34)
        .padding(.top, 28)
    }
}

private struct ProfileEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var profileName: String
    @Binding var accountNumber: String

    @State private var draftName: String = ""
    @State private var draftAccount: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Họ tên chủ tài khoản")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DTColor.muted)
                    TextField("Nhập họ tên", text: $draftName)
                        .font(.system(size: 18, weight: .medium))
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Số tài khoản")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DTColor.muted)
                    TextField("Nhập số tài khoản", text: $draftAccount)
                        .font(.system(size: 18, weight: .medium))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    profileName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                    accountNumber = draftAccount.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                } label: {
                    Text("Lưu thông tin")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(DTColor.blue, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(22)
            .navigationTitle("Thông tin hiển thị")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
            .onAppear {
                draftName = profileName
                draftAccount = accountNumber
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - PIN

private struct PINScreen: View {
    let onResult: (Bool) -> Void
    let onClose: () -> Void

    @State private var pin = ""
    @State private var wrong = false

    private let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]

    var body: some View {
        ZStack {
            Color(red: 0.975, green: 0.98, blue: 0.985).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 54, height: 54)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                VStack(spacing: 24) {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.14)).frame(width: 82, height: 82)
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.orange)
                    }

                    Text("Vui lòng nhập mã PIN")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(DTColor.muted)

                    HStack(spacing: 10) {
                        ForEach(0..<6, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .frame(width: 46, height: 64)
                                .overlay(
                                    Circle()
                                        .fill(index < pin.count ? DTColor.ink : Color.gray.opacity(0.20))
                                        .frame(width: 9, height: 9)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(wrong ? Color.red : (index == pin.count ? DTColor.ink : Color.black.opacity(0.05)), lineWidth: index == pin.count ? 1.2 : 0.8)
                                )
                        }
                    }

                    Text(wrong ? "Mã PIN không chính xác" : "Quên PIN?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(wrong ? .red : DTColor.ink)
                }
                .padding(.top, 8)

                Spacer()

                Image(systemName: "faceid")
                    .font(.system(size: 38))
                    .foregroundStyle(DTColor.blue)
                    .padding(.bottom, 28)

                NumericKeyboard(
                    onDigit: appendDigit,
                    onDelete: deleteDigit
                )
            }
        }
        .preferredColorScheme(.light)
    }

    private func appendDigit(_ digit: String) {
        guard pin.count < 6 else { return }
        wrong = false
        pin.append(digit)
        if pin.count == 6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                if pin == "000000" {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    onResult(true)
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    wrong = true
                    pin = ""
                }
            }
        }
    }

    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        wrong = false
        pin.removeLast()
    }
}

private struct NumericKeyboard: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    private let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { digit in
                        NumberPadButton(digit: digit, action: { onDigit(digit) })
                    }
                }
            }
            HStack(spacing: 8) {
                Color.clear.frame(maxWidth: .infinity, minHeight: 62)
                NumberPadButton(digit: "0", action: { onDigit("0") })
                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 62)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(Color(red: 0.80, green: 0.82, blue: 0.85))
    }
}

private struct NumberPadButton: View {
    let digit: String
    let action: () -> Void

    private var letters: String {
        switch digit {
        case "2": return "ABC"
        case "3": return "DEF"
        case "4": return "GHI"
        case "5": return "JKL"
        case "6": return "MNO"
        case "7": return "PQRS"
        case "8": return "TUV"
        case "9": return "WXYZ"
        default: return ""
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: -2) {
                Text(digit)
                    .font(.system(size: 31, weight: .regular))
                    .foregroundStyle(.black)
                if !letters.isEmpty {
                    Text(letters)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.black)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .background(.white, in: RoundedRectangle(cornerRadius: 5))
            .shadow(color: .black.opacity(0.25), radius: 0.5, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Accounts

private struct AccountsScreen: View {
    let accountNumber: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Tài khoản")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(DTColor.ink)
                    Spacer()
                    VStack(spacing: -3) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.orange)
                        Text("AI")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(DTColor.blue)
                    }
                }
                .padding(.horizontal, 36)
                .padding(.top, 28)

                VStack(spacing: 16) {
                    AccountCard(icon: "creditcard.fill", title: "Tài khoản thanh toán", detail: accountNumber.isEmpty ? "340 đ" : "STK \(accountNumber) · 340 đ", badge: nil, footer: nil)
                    AccountCard(icon: "chart.bar.fill", title: "Tài khoản Siêu Lợi Suất", detail: "Sinh lời mỗi ngày 8.0%", badge: "Hot", footer: "Kích hoạt ngay để tối ưu dòng tiền")
                    AccountCard(icon: "person.2.fill", title: "Quỹ nhóm", detail: "Chi tiêu cùng bạn bè", badge: "Mới", footer: "Mở ngay")
                    AccountCard(icon: "creditcard", title: "Mở thẻ tín dụng", detail: "Hoàn tiền đến 9%", badge: nil, footer: nil)
                    AccountCard(icon: "banknote.fill", title: "Tiền gửi trực tuyến", detail: "Gửi tiết kiệm, cộng lãi suất đến 2.2%", badge: nil, footer: nil)
                    AccountCard(icon: "dollarsign.square.fill", title: "Vay cầm cố sổ tiết kiệm", detail: "Giữ 100% lãi suất tiết kiệm", badge: nil, footer: nil)
                }
                .padding(.horizontal, 34)

                Color.clear.frame(height: 18)
            }
        }
        .background(DTColor.bg)
    }
}

private struct AccountCard: View {
    let icon: String
    let title: String
    let detail: String
    let badge: String?
    let footer: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DTColor.blue)
                    .frame(width: 54, height: 54)
                    .background(DTColor.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(DTColor.ink)
                    Text(detail)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DTColor.ink)
                }

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background(DTColor.blue, in: Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(DTColor.ink)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)

            if let footer {
                Text(footer)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(DTColor.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .frame(height: 50)
                    .background(DTColor.blue.opacity(0.07))
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Transactions

private struct TransactionsScreen: View {
    let onTransfer: () -> Void
    let onQR: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Giao dịch")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(DTColor.ink)
                    .padding(.horizontal, 36)
                    .padding(.top, 28)

                MenuSection(items: [
                    MenuItem(icon: "arrow.left.arrow.right.square.fill", title: "Chuyển tiền", action: onTransfer),
                    MenuItem(icon: "qrcode.viewfinder", title: "Quét mã QR", action: onQR),
                    MenuItem(icon: "person.2.fill", title: "Chuyển tiền nhóm", action: {}),
                    MenuItem(icon: "chart.xyaxis.line", title: "Chuyển tiền chứng khoán", action: {}),
                    MenuItem(icon: "envelope.badge.fill", title: "Yêu cầu thanh toán", action: {})
                ])

                MenuSection(items: [
                    MenuItem(icon: "plus.circle.fill", title: "Nạp tiền", action: {}),
                    MenuItem(icon: "dollarsign.square.fill", title: "Thanh toán", action: {}),
                    MenuItem(icon: "clock.badge.checkmark.fill", title: "Thanh toán tự động", action: {})
                ])

                MenuSection(items: [
                    MenuItem(icon: "chart.bar.fill", title: "Điều chỉnh hạn mức", action: {})
                ])

                Color.clear.frame(height: 20)
            }
        }
        .background(DTColor.bg)
    }
}

private struct MenuItem {
    let icon: String
    let title: String
    let action: () -> Void
}

private struct MenuSection: View {
    let items: [MenuItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button(action: item.action) {
                    HStack(spacing: 22) {
                        Image(systemName: item.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(DTColor.blue)
                            .frame(width: 42, height: 42)

                        Text(item.title)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(DTColor.ink)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(DTColor.ink.opacity(0.8))
                    }
                    .padding(.horizontal, 30)
                    .frame(height: 92)
                }
                .buttonStyle(.plain)

                if index != items.count - 1 {
                    Divider().padding(.leading, 88)
                }
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 34)
    }
}

// MARK: - Transfer

private struct TransferScreen: View {
    let onClose: () -> Void
    @State private var amount = "0"
    @State private var showRecipientSheet = false

    var body: some View {
        ZStack {
            Color(red: 0.975, green: 0.98, blue: 0.985).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 27, weight: .medium))
                            .foregroundStyle(DTColor.ink)
                            .frame(width: 54, height: 54)
                    }
                    Spacer()
                    Text("Chuyển tiền")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(DTColor.ink)
                    Spacer()
                    Color.clear.frame(width: 54, height: 54)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(amount)
                        .font(.system(size: 54, weight: .medium))
                        .foregroundStyle(DTColor.ink)
                    Text("đ")
                        .font(.system(size: 23))
                        .foregroundStyle(DTColor.muted)
                }
                .padding(.top, 38)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Chọn chuyển đến")
                        .font(.system(size: 18))
                        .foregroundStyle(DTColor.muted)

                    VStack(spacing: 0) {
                        TransferChoice(icon: "person.badge.plus", title: "Người nhận mới", action: { showRecipientSheet = true })
                        Divider().padding(.leading, 78)
                        TransferChoice(icon: "person.crop.square.fill", title: "Danh sách đã lưu", action: {})
                        Divider().padding(.leading, 78)
                        TransferChoice(icon: "doc.text.fill", title: "Mẫu chuyển tiền đã lưu", action: {})
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.horizontal, 34)
                .padding(.top, 48)

                Spacer()

                NumericKeyboard(onDigit: appendAmount, onDelete: deleteAmount)
            }
        }
        .sheet(isPresented: $showRecipientSheet) {
            NewRecipientSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private func appendAmount(_ digit: String) {
        if amount == "0" { amount = digit }
        else if amount.count < 12 { amount.append(digit) }
    }

    private func deleteAmount() {
        guard amount != "0" else { return }
        amount.removeLast()
        if amount.isEmpty { amount = "0" }
    }
}

private struct TransferChoice: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DTColor.blue)
                    .frame(width: 42)
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(DTColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(DTColor.ink)
            }
            .padding(.horizontal, 30)
            .frame(height: 94)
        }
        .buttonStyle(.plain)
    }
}

private struct NewRecipientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var account = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Chuyển tiền")
                        .font(.system(size: 21, weight: .bold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 52, height: 52)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)

                HStack(spacing: 0) {
                    Text("Đã lưu")
                        .foregroundStyle(DTColor.muted)
                        .frame(maxWidth: .infinity)
                    Text("Mới")
                        .foregroundStyle(DTColor.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 40)
                .padding(.top, 20)

                Text("Chọn hình thức chuyển")
                    .font(.system(size: 26, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 38)
                    .padding(.top, 34)

                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chuyển qua")
                            .font(.system(size: 15))
                            .foregroundStyle(DTColor.muted)
                        HStack {
                            Text("Số tài khoản")
                                .font(.system(size: 18, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(DTColor.muted)
                        }
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 76)
                    .background(.white, in: RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)

                    TextField("Nhập số tài khoản", text: $account)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18))
                        .padding(.horizontal, 18)
                        .frame(height: 72)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DTColor.ink.opacity(0.55), lineWidth: 1))
                }
                .padding(.horizontal, 38)
                .padding(.top, 28)

                Spacer()
            }
        }
    }
}

// MARK: - Cards

private struct CardsScreen: View {
    @State private var selectedCardTab = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Thẻ")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(DTColor.ink)
                    Spacer()
                    Image(systemName: "gift.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(DTColor.muted)
                }
                .padding(.horizontal, 36)
                .padding(.top, 28)

                HStack(spacing: 0) {
                    CardTab(title: "Thẻ tín dụng", selected: selectedCardTab == 0) { selectedCardTab = 0 }
                    CardTab(title: "Thẻ thanh toán", selected: selectedCardTab == 1) { selectedCardTab = 1 }
                }
                .padding(.horizontal, 34)

                VStack(spacing: 22) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.gray.opacity(0.08))
                            .frame(width: 280, height: 180)
                        VStack(spacing: 12) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(DTColor.blue)
                            Text("Duc Tue One Card")
                                .font(.system(size: 23, weight: .bold))
                        }
                    }

                    Text("Một thẻ cho mọi nhu cầu")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.06), radius: 4)

                    VStack(spacing: 8) {
                        Text("Hoàn đến 9% trên 3 danh mục cùng lúc")
                        Text("Chỉ từ 0% phí giao dịch ngoại tệ")
                        Text("Đặc quyền phòng chờ sân bay")
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(DTColor.ink)

                    Button(action: {}) {
                        Text("Mở thẻ ngay")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 34)
                            .frame(height: 58)
                            .background(
                                LinearGradient(colors: [Color.blue, DTColor.deepBlue], startPoint: .leading, endPoint: .trailing),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)

                    Text("Thẻ Duc Tue khác")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 18)
                }
                .frame(maxWidth: .infinity)

                Color.clear.frame(height: 20)
            }
        }
        .background(DTColor.bg)
    }
}

private struct CardTab: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? DTColor.ink : DTColor.muted)
                Capsule()
                    .fill(selected ? DTColor.blue : Color.clear)
                    .frame(width: 76, height: 4)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - More

private struct MoreScreen: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Khác")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(DTColor.ink)
                    .padding(.horizontal, 36)
                    .padding(.top, 28)

                MenuSection(items: [
                    MenuItem(icon: "star.hexagon.fill", title: "Hạng hội viên", action: {}),
                    MenuItem(icon: "gift.fill", title: "Ưu đãi", action: {})
                ])

                MenuSection(items: [
                    MenuItem(icon: "bell.fill", title: "Thông báo", action: {}),
                    MenuItem(icon: "person.2.fill", title: "Bạn bè", action: {}),
                    MenuItem(icon: "message.fill", title: "Dịch vụ SMS Banking", action: {}),
                    MenuItem(icon: "medal.fill", title: "Duc Tue Rewards", action: {}),
                    MenuItem(icon: "checkmark.shield.fill", title: "Quản lý bảo hiểm", action: {})
                ])

                MenuSection(items: [
                    MenuItem(icon: "info.circle.fill", title: "Thông tin & trợ giúp", action: {}),
                    MenuItem(icon: "lock.fill", title: "Bảo mật", action: {})
                ])

                Color.clear.frame(height: 20)
            }
        }
        .background(DTColor.bg)
    }
}

// MARK: - Bottom bar

private struct MainTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(String, String)] = [
        ("house.fill", "Trang chủ"),
        ("person.fill", "Tài khoản"),
        ("arrow.left.arrow.right.square.fill", "Giao dịch"),
        ("creditcard.fill", "Thẻ"),
        ("ellipsis", "Khác")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    selectedTab = index
                } label: {
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(selectedTab == index ? DTColor.blue : Color.clear)
                            .frame(width: 46, height: 4)
                        Image(systemName: tab.0)
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(selectedTab == index ? DTColor.blue : Color.gray.opacity(0.62))
                        Text(tab.1)
                            .font(.system(size: 13, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? DTColor.ink : Color.gray.opacity(0.70))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
        .background(.white)
        .overlay(alignment: .top) { Divider() }
    }
}

// MARK: - Small components

private struct OutlineAction: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(Capsule().stroke(.white.opacity(0.95), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

private struct FeatureItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(DTColor.blue)
                    .frame(height: 30)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DTColor.ink)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct TransactionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DTColor.blue)
                .frame(width: 40, height: 40)
                .background(DTColor.blue.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(amount)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.vertical, 12)
    }
}

struct QRDemoView: View {
    var body: some View {
        VStack(spacing: 22) {
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            Text("Quét QR")
                .font(.system(size: 24, weight: .bold))

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 230, height: 230)
                Image(systemName: "qrcode")
                    .font(.system(size: 145))
                    .foregroundStyle(DTColor.ink)
            }

            Text("QR mô phỏng — không thực hiện giao dịch thật")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
