do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math
    {Line, Color, AmbientLight, DirectionalLight, Plate, Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    DEG_TO_RAD = PI / 180

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

    # 各素材のUV Dataを定義
    ground_1_uv = [
        0  , 0  ,
        0.5, 0  ,
        0  , 0.5
    ]

    ground_2_uv = [
        0  , 0.5,
        0.5, 0  ,
        0.5, 0.5
    ]

    roof_1_uv = [
        0  , 0  ,
        0.5, 0  ,
        0  , 0.5
    ]

    roof_2_uv = [
        0  , 0.5,
        0.5, 0  ,
        0.5, 0.5
    ]

    wall_1_uv = [
        0.0, 0.5
        0.0, 1.0
        0.5, 0.5
    ]

    wall_2_uv = [
        0.0, 1.0
        0.5, 1.0
        0.5, 0.5
    ]

    wall_3_uv = [
        0.5, 0,
        1  , 0,
        0.5, 0.5
    ]

    wall_4_uv = [
        0.5, 0.5,
        1  , 0,
        1  , 0.5
    ]

    wall_5_uv = [
        0.5, 0,
        1  , 0,
        0.5, 0.5
    ]

    wall_6_uv = [
        0.5, 0.5,
        1  , 0,
        1  , 0.5
    ]

    wall_7_uv = [
        0  , 0.5,
        0.5, 0.5,
        0  , 1
    ]

    wall_8_uv = [
        0  , 1,
        0.5, 0.5,
        0.5, 1
    ]


    textureImage = null
    logoImage    = null
    photoImage   = null
    rotX = 0
    rotY = 0

    renderer = null
    camera   = null
    scene    = null

    init = ->
        cv  = doc.getElementById 'canvas'
        ctx = cv.getContext '2d'
        w = cv.width  = win.innerWidth
        h = cv.height = win.innerHeight
        fov = 60
        aspect = w / h

        cnt = 3
        img = new Image()
        logo = new Image()
        photo = new Image()

        img.onload = ->
            textureImage = img
            --cnt or create()

        logo.onload = ->
            logoImage = logo
            --cnt or create()

        photo.onload = ->
            photoImage = photo
            --cnt or create()

        img.src = 'img/aXjiA.png'
        logo.src = 'img/HTML5_Logo_512.png'
        photo.src = 'img/photo.jpg'
        #photo.src = 'http://jsrun.it/assets/y/r/A/V/yrAVl.jpg'
        #logo.src = 'http://jsrun.it/assets/z/1/2/9/z129U.png'
        #img.src = 'http://jsrun.it/assets/k/M/J/J/kMJJS.png'

        camera = new Camera 40, aspect, 1, 5000
        camera.position.x = 10
        camera.position.y = 50
        camera.position.z = 200
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 50, 0, 0
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        renderer.fog = true
        renderer.wireframe = true

        create = ->

            materials = [
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
                new Texture(photoImage, [0, 0, 0, 1, 1, 0])
                new Texture(photoImage, [0, 1, 1, 1, 1, 0])
            ]

            cube1 = new Cube 50, 20, 20, 1, 1, 1, materials
            cube1.position.z = -50
            cube1.rotation.z = 30

            cube2 = new Cube 20, 20, 20, 1, 1, 1, materials
            cube2.position.z = -150
            cube2.position.x = 50

            cube3 = new Cube 20, 20, 20, 1, 1, 1, materials
            cube3.position.z = -350
            cube3.position.x = 50
            cube3.position.y = 80

            plate1 = new Plate 50, 50, new Texture(textureImage, wall_1_uv), new Texture(textureImage, wall_2_uv)
            plate1.position.x = -50
            plate1.position.z = -300

            plate2 = new Plate 50, 50, new Texture(logoImage, [0, 0, 0, 1, 1, 0]), new Texture(logoImage, [0, 1, 1, 1, 1, 0])
            plate2.position.y = -100
            plate2.position.z = -500

            line1 = new Line(new Vector3(0, 0, -100), new Vector3(0, 0, 100))
            line2 = new Line(new Vector3(-100, 0, 0), new Vector3(100, 0, 0))
            line3 = new Line(new Vector3(0, 100, 0), new Vector3(0, -100, 0))
            line4 = new Line(new Vector3(50, 50, 50), new Vector3(-50, -50, -50))

            ambLight = new AmbientLight(new Color(255, 0, 0, 0.2))
            dirLight = new DirectionalLight(new Color(0, 0, 70, 0.3), (new Vector3(1, 0, -1)).normalize())
           
            #scene.add ambLight
            #scene.add dirLight

            scene.add plate1
            scene.add plate2
            scene.add cube1
            scene.add cube2
            scene.add cube3
            scene.add line1
            scene.add line2
            scene.add line3
            scene.add line4

            angle = 0
            do _loop = ->
                angle += 1
                plate1.rotation.z = angle
                plate2.rotation.x = angle * 3
                cube1.rotation.z = angle
                cube2.rotation.x = angle * 2
                cube3.rotation.x = angle * 3
                cube3.rotation.y = angle * 3
                cube3.rotation.z = angle * 3
                renderer.render scene, camera
                #setTimeout _loop, 32

    dragging = false
    prevX = 0
    prevY = 0

    # Events
    win.addEventListener 'mousewheel', (e) ->
        camera.position.z += (e.wheelDelta / 100)
        renderer.render scene, camera
        e.preventDefault()
    , false

    base = 100
    startZoom = 0
    document.addEventListener 'gesturechange', (e) ->
        num =  e.scale * base - base
        camera.position.z = startZoom - num
        renderer.render scene, camera
        e.preventDefault()
    , false
    
    document.addEventListener 'gesturestart', ->
        startZoom = camera.position.z
    , false

    doc.addEventListener 'touchstart', (e) ->
        e.preventDefault()
    , false

    doc.addEventListener MOUSE_DOWN, (e) ->
        dragging = true
        prevX = if isTouch then e.touches[0].pageX else e.pageX
        prevY = if isTouch then e.touches[0].pageY else e.pageY
    , false

    doc.addEventListener MOUSE_MOVE, (e) ->
        return if dragging is false

        pageX = if isTouch then e.touches[0].pageX else e.pageX
        pageY = if isTouch then e.touches[0].pageY else e.pageY

        rotY += (prevX - pageX) / 100
        rotX += (prevY - pageY) / 100

        camera.setWorld(Matrix4.multiply((new Matrix4()).rotationY(rotY), (new Matrix4()).rotationX(rotX)))

        prevX = pageX
        prevY = pageY
        
        renderer.render scene, camera
    , false

    doc.addEventListener MOUSE_UP, (e) ->
        dragging = false
    , false

    doc.addEventListener 'DOMContentLoaded', init, false
