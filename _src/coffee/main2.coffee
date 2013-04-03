do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math
    {Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

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
        0  , 0.5,
        0.5, 0.5,
        0  , 1
    ]

    wall_2_uv = [
        0  , 1,
        0.5, 0.5,
        0.5, 1
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
        img = new Image()

        img.onload = ->
            textureImage = img
            create()

        img.src = 'img/aXjiA.png'
        #img.src = 'http://jsrun.it/assets/k/M/J/J/kMJJS.png'

        camera = new Camera 60, aspect, 5, 2000
        camera.position.x = 10
        camera.position.y = 50
        camera.position.z = 80
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 0, 0
        scene    = new Scene
        renderer = new Renderer cv, '#eee'

        create = ->
            materials = [
                new Texture textureImage, roof_1_uv #top1
                new Texture textureImage, roof_2_uv #top2
                new Texture textureImage, wall_1_uv #bottom1
                new Texture textureImage, wall_2_uv #bottom2
                new Texture textureImage, wall_3_uv #front1
                new Texture textureImage, wall_4_uv #front2
                new Texture textureImage, wall_5_uv #back1
                new Texture textureImage, wall_6_uv #back2
                new Texture textureImage, wall_3_uv #wall1
                new Texture textureImage, wall_4_uv #wall2
                new Texture textureImage, wall_5_uv #wall3
                new Texture textureImage, wall_6_uv #wall4
                new Texture textureImage, wall_7_uv #wall5
                new Texture textureImage, wall_8_uv #wall6
            ]

            cube1 = new Cube 20, 20, 20, 1, 1, 1, materials
            cube1.position.z = -50
            cube1.rotation.z = 30

            cube2 = new Cube 20, 20, 20, 1, 1, 1, materials
            cube2.position.z = -150
            cube2.position.x = 50

            cube3 = new Cube 20, 20, 20, 1, 1, 1, materials
            cube3.position.z = -350
            cube3.position.x = 50
            cube3.position.y = 80

            scene.add cube3
            scene.add cube2
            scene.add cube1

            renderer.render scene, camera

    dragging = false
    prevX = 0
    prevY = 0

    # Events
    win.addEventListener 'mousewheel', (e) ->
        camera.position.z += (e.wheelDelta / 100)
        renderer.render scene, camera
        e.preventDefault()
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
