import SwiftUI

struct SplashView: View {
    // Animation phases
    @State private var phase: AnimationPhase = .rotating
    @State private var rotationY: Double = 0
    @State private var dropVisible = false
    @State private var dropY: CGFloat = -80
    @State private var splashVisible = false
    @State private var splashDroplets: [SplashDroplet] = []
    @State private var textVisible = false
    @State private var textScale: CGFloat = 0.3
    
    enum AnimationPhase {
        case rotating, dropping, splashing, forming
    }
    
    var body: some View {
        ZStack {
            // Solid white background
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Gas pump nozzle with 3D rotation
                Image("GasPump")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .rotation3DEffect(
                        .degrees(rotationY),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.4
                    )
                
                Spacer()
                    .frame(height: 40)
                
                // Drop, splash, and text area
                ZStack {
                    // Falling drop
                    if dropVisible {
                        DropShape()
                            .fill(Color.black)
                            .frame(width: 35, height: 50)
                            .offset(y: dropY)
                    }
                    
                    // Splash droplets
                    ForEach(splashDroplets) { droplet in
                        Circle()
                            .fill(Color.black)
                            .frame(width: droplet.size, height: droplet.size)
                            .offset(x: droplet.x, y: droplet.y)
                            .opacity(droplet.opacity)
                    }
                    
                    // Puddle
                    if splashVisible {
                        Ellipse()
                            .fill(Color.black)
                            .frame(width: 100, height: 25)
                            .offset(y: 60)
                    }
                    
                    // Final text
                    if textVisible {
                        Text("oktan")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .scaleEffect(textScale)
                            .offset(y: 20)
                    }
                }
                .frame(height: 200)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // PHASE 1: Rotate pump slowly (0-2s)
        withAnimation(.easeInOut(duration: 2.0)) {
            rotationY = 360
        }
        
        // PHASE 2: Drop falls (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dropVisible = true
            
            withAnimation(.easeIn(duration: 0.5)) {
                dropY = 60
            }
        }
        
        // PHASE 3: Splash (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dropVisible = false
            splashVisible = true
            createSplashDroplets()
            animateSplash()
        }
        
        // PHASE 4: Droplets converge to form text (3.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            convergeDropletsToText()
        }
        
        // PHASE 5: Show text (3.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            textVisible = true
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                textScale = 1.0
            }
            
            // Fade out droplets
            withAnimation(.easeOut(duration: 0.3)) {
                for i in splashDroplets.indices {
                    splashDroplets[i].opacity = 0
                }
                splashVisible = false
            }
        }
    }
    
    private func createSplashDroplets() {
        splashDroplets = (0..<20).map { i in
            SplashDroplet(
                id: i,
                x: CGFloat.random(in: -10...10),
                y: 55,
                size: CGFloat.random(in: 8...16),
                opacity: 1.0
            )
        }
    }
    
    private func animateSplash() {
        withAnimation(.easeOut(duration: 0.4)) {
            for i in splashDroplets.indices {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 60...140)
                splashDroplets[i].x = cos(angle) * distance
                splashDroplets[i].y = 40 + sin(angle) * distance * 0.4
            }
        }
    }
    
    private func convergeDropletsToText() {
        withAnimation(.easeInOut(duration: 0.5)) {
            for i in splashDroplets.indices {
                // Move droplets to where text will appear
                splashDroplets[i].x = CGFloat.random(in: -80...80)
                splashDroplets[i].y = CGFloat.random(in: 0...40)
                splashDroplets[i].size = CGFloat.random(in: 4...10)
            }
        }
    }
}

// MARK: - Drop Shape

struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Teardrop
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

// MARK: - Splash Droplet

struct SplashDroplet: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

#Preview {
    SplashView()
}
