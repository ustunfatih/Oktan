import SwiftUI

struct SplashView: View {
    // Configuration for each oil drop
    struct DropConfig {
        let char: String
        let landX: CGFloat        // X Position where it lands (under Island)
        let finalX: CGFloat       // X Position in the final word
        let size: CGFloat         // Size of the drop
        let delay: Double         // Start delay
        let formDuration: Double  // Time to form at top
        let fallDuration: Double  // How fast it falls
    }
    
    // Configured for "oktan"
    // Drops fall from random spots under the Dynamic Island (approx width 120pt, so -60 to 60)
    // Then expand to final word positions.
    let drops: [DropConfig] = [
        DropConfig(char: "o", landX: -20, finalX: -90, size: 22, delay: 0.1, formDuration: 1.2, fallDuration: 0.60),
        DropConfig(char: "k", landX: 10,  finalX: -45, size: 26, delay: 0.8, formDuration: 1.0, fallDuration: 0.45),
        DropConfig(char: "t", landX: -5,  finalX: -5,  size: 28, delay: 0.4, formDuration: 1.4, fallDuration: 0.50),
        DropConfig(char: "a", landX: 25,  finalX: 35,  size: 20, delay: 1.2, formDuration: 0.9, fallDuration: 0.55),
        DropConfig(char: "n", landX: -15, finalX: 80,  size: 24, delay: 0.6, formDuration: 1.1, fallDuration: 0.48)
    ]
    
    @State private var expandToWord = false
    
    var body: some View {
        ZStack {
            // Off-white gradient background
            LinearGradient(
                colors: [Color.white, Color(uiColor: UIColor.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                // Dynamic Island bottom ~54pt. Start slightly higher so they emerge.
                let startY: CGFloat = 55
                
                ForEach(drops.indices, id: \.self) { index in
                    let config = drops[index]
                    OilDropView(
                        config: config,
                        centerX: centerX,
                        startY: startY,
                        targetY: centerY,
                        expandToWord: expandToWord
                    )
                }
            }
        }
        .task {
            // Wait for all drops to splash (max time approx 3.0s)
            // Longest sequence: 'a' (1.2 delay + 0.9 form + 0.9 wait + 0.55 fall = ~3.55s)
            try? await Task.sleep(for: .seconds(3.6))
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                expandToWord = true
            }
        }
    }
}

struct OilDropView: View {
    let config: SplashView.DropConfig
    let centerX: CGFloat
    let startY: CGFloat
    let targetY: CGFloat
    let expandToWord: Bool
    
    // Animation States
    @State private var yPosition: CGFloat
    @State private var dropScale: CGSize = CGSize(width: 0.1, height: 0.1)
    @State private var isSplashed = false
    
    // Letter & Splash States
    @State private var letterScale: CGFloat = 0.5
    @State private var letterOpacity: Double = 0.0
    @State private var splashScale: CGFloat = 0.5
    @State private var splashOpacity: Double = 0.8
    
    init(config: SplashView.DropConfig, centerX: CGFloat, startY: CGFloat, targetY: CGFloat, expandToWord: Bool) {
        self.config = config
        self.centerX = centerX
        self.startY = startY
        self.targetY = targetY
        self.expandToWord = expandToWord
        self._yPosition = State(initialValue: startY)
    }
    
    var currentX: CGFloat {
        if expandToWord {
            return centerX + config.finalX
        } else {
            return centerX + config.landX
        }
    }
    
    var body: some View {
        ZStack {
            if !isSplashed {
                // FALLING OIL DROP
                DropShape()
                    .fill(Color.black)
                    .frame(width: config.size, height: config.size * 1.5)
                    .scaleEffect(dropScale, anchor: .top)
                    .position(x: centerX + config.landX, y: yPosition) // Falls straight down
            } else {
                // IMPACT SPLASH
                Circle()
                    .stroke(Color.black, lineWidth: 2.5)
                    .frame(width: config.size, height: config.size)
                    .scaleEffect(splashScale)
                    .opacity(splashOpacity)
                    .position(x: centerX + config.landX, y: targetY) // Splash stays where it landed
                
                // LETTER (Moves during expansion)
                Text(config.char)
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(Color.black)
                    .position(x: currentX, y: targetY)
                    .scaleEffect(letterScale)
                    .opacity(letterOpacity)
            }
        }
        .task {
            // 1. Delay
            if config.delay > 0 {
                try? await Task.sleep(for: .seconds(config.delay))
            }
            
            // 2. Form (Grow)
            withAnimation(.easeInOut(duration: config.formDuration)) {
                dropScale = CGSize(width: 1.0, height: 1.0)
            }
            // Wait for form + suspense
            try? await Task.sleep(for: .seconds(config.formDuration + 0.2))
            
            // 3. Fall
            withAnimation(.easeIn(duration: config.fallDuration)) {
                yPosition = targetY
            }
            try? await Task.sleep(for: .seconds(config.fallDuration - 0.05))
            
            // 4. Impact
            isSplashed = true
            
            // Splash Animation
            withAnimation(.easeOut(duration: 0.4)) {
                splashScale = 2.5
                splashOpacity = 0.0
            }
            
            // Letter Appear
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                letterScale = 1.0
                letterOpacity = 1.0
            }
        }
    }
}

// Standard Teardrop
struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w / 2, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.65),
            control: CGPoint(x: w, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w / 2, y: h),
            control1: CGPoint(x: w, y: h * 0.9),
            control2: CGPoint(x: w * 0.65, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.65),
            control1: CGPoint(x: w * 0.35, y: h),
            control2: CGPoint(x: 0, y: h * 0.9)
        )
        path.addQuadCurve(
            to: CGPoint(x: w / 2, y: 0),
            control: CGPoint(x: 0, y: h * 0.2)
        )
        return path
    }
}

#Preview {
    SplashView()
}
