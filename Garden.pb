;Garden

EnableExplicit

;Scene
Global Camera, Light

;Leaves
Structure NewLeave
  Mesh.i
  Entity.i
  x.f
  y.f
  z.f
  angle.f
EndStructure
Global Dim Leaves.NewLeave(200), LeavesMat, Index

;Sounds
Global SoundLeft, SoundCentral, SoundRight
Global HubCentral, HubLeft, HubRight

;EyeBall
Global EyeBall, EyeBallMesh, EyeBallTex, EyeBallMat

;Particle
Global Emitter, Particle, ParticleTex, ParticleMat 

;Mouse move
Global Pointer, UserX.f, UserY.f

;Summary
Declare GameLoad()
Declare RenderGame3D()
Declare RenderGame2D() 
Declare Exit()

; Returns a random float in the interval [0.0, Maximum]
Macro RandomFloat(Maximum=1.0)
  ( Random(2147483647)*Maximum*4.6566128752457969241e-10 ) ; Random * 1/MaxRandom
EndMacro

; Returns a random sign {-1, 1}
Macro RandomSign()
  ( Random(1)*2-1 ) 
EndMacro

GameLoad()

Procedure GameLoad()
  Protected Window 
    
  If InitEngine3D() And  InitKeyboard() And InitSprite() And InitMouse() And InitSound()
    Window = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_Maximize | #PB_Window_BorderLess)
    SetWindowColor(Window, 0)
    
    ;-[Screen]
    OpenWindowedScreen(WindowID(Window),0, 0, WindowWidth(Window) , WindowHeight(Window))    
    KeyboardMode(#PB_Keyboard_International)  

    ;-[2D]
    ;Arrow
    UsePNGImageDecoder()
    Pointer = LoadSprite(#PB_Any, "assets/image/arrow4.png", #PB_Sprite_AlphaBlending )  
    ZoomSprite(Pointer, 50, 50)
    
    ;-[3D]
    Add3DArchive("assets/image", #PB_3DArchive_FileSystem)
    Add3DArchive("assets/sound", #PB_3DArchive_FileSystem)
        
    ;-Camera
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    CameraBackColor(Camera, RGB(0, 0, 0))
    MoveCamera(Camera, 0, 0, -10)
    CameraLookAt(Camera, 0, 0, 0)
    
    ;-Light
    Light = CreateLight(#PB_Any, RGB(255, 255, 255), 0, 0, 0, #PB_Light_Point)
    SetLightColor(Light, #PB_Light_SpecularColor, RGB(255, 255, 255))
    SetLightColor(Light, #PB_Light_DiffuseColor, RGB(255, 255, 255))
    
    ;-Sound
    SoundCentral = LoadSound3D(#PB_Any, "ambiance.wav")    
    SoundLeft = LoadSound3D(#PB_Any, "gong.wav")
    SoundRight = LoadSound3D(#PB_Any, "drum.wav")
    
    ;Sound Hub
    HubCentral = CreateNode(#PB_Any, 0, 0, 10)
    AttachNodeObject(HubCentral, SoundID3D(SoundCentral))
    SoundRange3D(SoundCentral, 1, 40)
    PlaySound3D(SoundCentral, #PB_Sound3D_Loop)
    
    HubLeft = CreateNode(#PB_Any, 30, 0, 10)
    AttachNodeObject(HubLeft, SoundID3D(SoundLeft))
    SoundRange3D(SoundLeft, 1, 40)
    PlaySound3D(SoundLeft, #PB_Sound3D_Loop)
    
    HubRight = CreateNode(#PB_Any, -30, 0, 10)
    AttachNodeObject(HubRight, SoundID3D(SoundRight))
    SoundRange3D(SoundRight, 1, 40)
    PlaySound3D(SoundRight, #PB_Sound3D_Loop)
           
    ;-Particle
    ParticleTex = LoadTexture(#PB_Any, "particle.png")
    ParticleMat = CreateMaterial(#PB_Any, TextureID(ParticleTex))
    DisableMaterialLighting(ParticleMat, #True)
    MaterialBlendingMode(ParticleMat, #PB_Material_Add)

    Emitter = CreateParticleEmitter(#PB_Any, 100, 100, 100, #PB_Particle_Box)
    ParticleMaterial(Emitter, MaterialID(ParticleMat))
    ParticleTimeToLive(Emitter, 1, 3)
    ParticleEmissionRate(Emitter, 200)
    ParticleSize(Emitter, 1, 1)   
    
    ;-Leaves
    Global LeavesTex = LoadTexture(#PB_Any, "viny_leaves.png")
    LeavesMat = CreateMaterial(#PB_Any, TextureID(LeavesTex))   
    MaterialBlendingMode(LeavesMat, #PB_Material_AlphaBlend)
    
    For Index = 0 To 199
      With Leaves(Index)
        \Mesh = CreatePlane(#PB_Any, 4, 4, 1, 1, 1, 1)
        \Entity = CreateEntity(#PB_Any, MeshID(\Mesh), MaterialID(LeavesMat)) 
        \x = Random(15) * RandomSign()
        \y = Random(2) * RandomSign()        
        \z = Random(30) * RandomSign()
        \angle = RandomFloat(0.1) * RandomSign()
        MoveEntity(\Entity, \x, \y, \z) 
        RotateEntity(\Entity, -90, 0, 0)
      EndWith
    Next  
    
    ;-Eye Ball
    EyeBallMesh = CreateSphere(#PB_Any, 2)
    EyeBallTex = LoadTexture(-1, "EYE.png")
    EyeBallMat = CreateMaterial(#PB_Any, TextureID(EyeBallTex))
    ScaleMaterial(EyeBallMat, 0.5, 1)
    EyeBall = CreateEntity(-1, MeshID(EyeBallMesh), MaterialID(EyeBallMat), 0, 0, 20)
    
    ;-Loop
    While #True
      Repeat : Until WindowEvent() = 0
      FlipBuffers()  
      RenderGame3D()
      RenderWorld()
      RenderGame2D()
    Wend
  Else
    
  EndIf 
EndProcedure

Procedure RenderGame3D()  
  Protected x.f = CameraX(Camera) + ((UserX * -10) - CameraX(Camera)) * 0.05  
  Protected z.f = CameraZ(Camera) + ((UserY * -10) - CameraZ(Camera)) * 0.05  
  
  If ExamineKeyboard()
    If KeyboardReleased(#PB_Key_Escape)
      Exit()
    EndIf  
  EndIf
  
  If ExamineMouse()
    UserX =  -1 + (MouseX()/ScreenWidth()) * 2 
    UserY =  -1 + (MouseY()/ScreenHeight()) * 2 
  EndIf
  
  For Index = 0 To 199
    With Leaves(Index)
      RotateEntity(\Entity, 0, \angle, 0, #PB_Relative)
    EndWith
  Next  
  
  MoveCamera(Camera, x, 0, z, #PB_Absolute) 
  SoundListenerLocate(CameraX(Camera), CameraY(Camera), CameraZ(Camera))
   
  ;Eye follow camera
  EntityLookAt(EyeBall, x, 0, z) 
 
EndProcedure

Procedure RenderGame2D()
  ;25 = Pointer width  / 2
  DisplayTransparentSprite(Pointer, MouseX()-25, MouseY()-25)
EndProcedure

Procedure Exit()
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 102
; FirstLine = 70
; Folding = --
; EnableXP