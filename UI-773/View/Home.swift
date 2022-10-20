//
//  Home.swift
//  UI-773
//
//  Created by nyannyan0328 on 2022/10/20.
// SCROLLER

import SwiftUI

struct Home: View {
    @State var characters : [Character] = []
     @State var startOffset  : CGFloat = 0
    @State var scrollerHeight  : CGFloat = 0
    @State var indicatorOffset  : CGFloat = 0
    
     @State var hideIndicatorLabel : Bool = false
    
    @State var timeOut  : CGFloat = 0
    
    @State var currentCharacter : Character = .init(value: "")
    var body: some View {
        NavigationStack{
            GeometryReader{
                
                let size = $0.size
             
                ScrollViewReader { proxy in
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        VStack(spacing: 0) {
                            
                            ForEach(characters){character in
                                
                                CotractCharacters(character: character)
                                    .id(character.index)
                                
                            }
                            
                        }
                        .padding()
                        .padding(.trailing,20)
                        .offset { rect in
                            
                            if hideIndicatorLabel && rect.minY < 0{
                                
                                timeOut = 0
                                hideIndicatorLabel = false
                            }
                            
                            let rectH = rect.height
                            let viewH = size.height + (startOffset / 2)
                            
                            let scrollH = (viewH / rectH) * viewH
                            
                            self.scrollerHeight = scrollH
                            
                            
                            let progress = rect.minY / (rectH - size.height)
                            
                            self.indicatorOffset = -progress * (size.height - scrollH)
                            
                        }
                        
                    }
                }
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .overlay(alignment: .topTrailing) {
                      
                      
                      Rectangle()
                          .fill(.clear)
                          .frame(width:2,height: scrollerHeight)
                          .offset(y:indicatorOffset)
                          .overlay(alignment: .trailing) {
                              
                             Image(systemName: "bubble.middle.bottom.fill")
                                  .resizable()
                                  .renderingMode(.template)
                                  .aspectRatio(contentMode: .fit)
                                  .foregroundStyle(.ultraThinMaterial)
                                  .frame(width: 45,height: 45)
                                  .rotationEffect(.init(degrees: 90))
                                  .overlay(content: {
                                      
                                      Text(currentCharacter.value)
                                          .font(.largeTitle)
                                          .foregroundColor(.black)
                                      
                                   
                                  })
                                  .environment(\.colorScheme, .dark)
                                  .offset(x:hideIndicatorLabel || currentCharacter.value == "" ? 65 : 0)
                                  .animation(.interactiveSpring(response: 0.6,dampingFraction: 0.6,blendDuration: 0.7), value: hideIndicatorLabel || currentCharacter.value == "")
                                  
                            
                          }
                  }
                  .coordinateSpace(name: "SCROLLER")
            }
            .navigationTitle("Character")
            .offset { rect in
                if startOffset != rect.minY{
                    
                    startOffset = rect.minY
                }
                
            }
        }
        .onAppear{characters = fetchCharactes()}
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            
            
            if timeOut < 0.3{
                
                timeOut += 0.1
            }
            else{
                
                if !hideIndicatorLabel{
                    hideIndicatorLabel = true
                    
                    
                }
            }
            
           
        }
    }
    @ViewBuilder
    func CotractCharacters(character : Character)->some View{
        
        
        VStack(alignment:.leading,spacing: 10){
            Text(character.value)
                .font(.largeTitle.bold())
            
            ForEach(1...4 ,id:\.self){index in
                HStack{
                    
                   Circle()
                        .fill(character.color)
                        .frame(width: 60,height: 60)
                       .shadow(color: .black.opacity(0.07), radius: 5,x:5,y:5)
                    
                    VStack{
                        
                       RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color.gradient.opacity(0.5))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                             .fill(character.color.gradient.opacity(0.5))
                             .frame(height: 20)
                             .padding(.trailing,160)
                            
                    }
                 
                    
                    
                    
                }
                
                
            }
        }
        
        .offset { rect in
            if characters.indices.contains(character.index){
                
                characters[character.index].rect = rect
            }
            
           
            if let last = characters.last(where: { char in
                
                char.rect.minY < 0
                
            }),last.id != currentCharacter.id{
                
                currentCharacter = last
                
            }
        }
        .padding(15)
        
    }
    
    func fetchCharactes()->[Character]{
        
        let alphabet : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var charcters : [Character] = []
        charcters = alphabet.compactMap({ character->Character? in
            
            return Character(value: String(character))
        })
        
        let colors : [Color] = [.red,.yellow,.gray,.green,.orange,.purple,.indigo,.blue,.pink]
        
        for index in charcters.indices{
            
            charcters[index].index = index
            charcters[index].color = colors.randomElement()!
        }
        
        
        
        return charcters
        
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{
    
    @ViewBuilder
    func offset(comeption : @escaping(CGRect)->())->some View{
        
        self
            .overlay {
                
                GeometryReader{
                    
                    let size = $0.frame(in: .named("SCROLLER"))
                    
                    Color.clear
                        .preference(key : OffsetKey.self, value: size)
                        .onPreferenceChange(OffsetKey.self) { value in
                            comeption(value)
                        }
                    
                    
                }
            }
    }
}

struct OffsetKey : PreferenceKey{
    
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
