do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math
    {Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    DEG_TO_RAD = PI / 180

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

    # 各種素材の座標を定義
    #
    # 3次元上のTriangle座標を指定
    # |x1, y1, z1|
    # |x2, y2, z2|
    # |x3, y3, z3|

    roof_1 = [
        -4,  4,  4
         4,  4,  4
        -4,  4, -4
    ]

    roof_2 = [
        -4,  4, -4
         4,  4,  4
         4,  4, -4
    ]

    ground_1 = [
        -10, -4,  10
         10, -4,  10
        -10, -4, -10
    ]

    ground_2 = [
        -10, -4, -10
         10, -4,  10
         10, -4, -10
    ]

    wall_1 = [
        -4,  4,  -4
        4,  4,  -4
        -4, -4,  -4
    ]

    wall_2 = [
        -4, -4, -4
        4,  4, -4
        4, -4, -4
    ]

    wall_3 = [
        -4,  4,   4
        -4,  4,  -4
        -4, -4,   4
    ]

    wall_4 = [
        -4, -4,  4
        -4,  4, -4
        -4, -4, -4
    ]

    wall_5 = [
        4,  4,  -4
        4,  4,   4
        4, -4,  -4
    ]

    wall_6 = [
        4, -4, -4
        4,  4,  4
        4, -4,  4
    ]

    wall_7 = [
        4,  4, 4
        -4,  4, 4
        4, -4, 4
    ]

    wall_8 = [
        4, -4, 4
        -4,  4, 4
        -4, -4, 4
    ]

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
    groundImage = null
    rotX = 0
    rotY = 0
    rotZ = 0

    renderer = null
    camera = null
    scene = null

    start = ->
        img = new Image()
        img2 = new Image()
        img.onload = ->
            textureImage = img
            renderer.render scene, camera

        img2.onload = ->
            groundImage = img2
            renderer.render scene, camera

        img.src = 'img/aXjiA.png'
        img2.src = 'img/8uu1X.png'

    init = ->

        cv  = doc.getElementById 'canvas'
        ctx = cv.getContext '2d'
        w = cv.width = win.innerWidth
        h = cv.height = win.innerHeight
        fov = 60
        aspect = w / h
        cnt = 2
        img = new Image()
        img2 = new Image()

        img.onload = ->
            textureImage = img
            --cnt or create()

        img2.onload = ->
            groundImage = img2
            --cnt or create()

        img.src = 'img/aXjiA.png'
        img2.src = 'img/8uu1X.png'

        camera = new Camera 60, aspect, 5, 2000
        camera.position.x = 10
        camera.position.y = 10
        camera.position.z = 80
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 0, 0
        scene = new Scene
        renderer = new Renderer cv

        create = ->

            #texture = new Texture(groundImage, ground_1_uv)
            #triangle = new Triangle(ground_1, texture)
            #scene.add triangle
            #
            #texture = new Texture(groundImage, ground_2_uv)
            #triangle = new Triangle(ground_2, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, roof_1_uv)
            #triangle = new Triangle(roof_1, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, roof_2_uv)
            #triangle = new Triangle(roof_2, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_1_uv)
            #triangle = new Triangle(wall_1, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_2_uv)
            #triangle = new Triangle(wall_2, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_3_uv)
            #triangle = new Triangle(wall_3, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_4_uv)
            #triangle = new Triangle(wall_4, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_5_uv)
            #triangle = new Triangle(wall_5, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_6_uv)
            #triangle = new Triangle(wall_6, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_7_uv)
            #triangle = new Triangle(wall_7, texture)
            #scene.add triangle
            #
            #texture = new Texture(textureImage, wall_8_uv)
            #triangle = new Triangle(wall_8, texture)
            #scene.add triangle
            #
            #t1 = new Texture(textureImage, roof_1_uv)
            #t2 = new Texture(textureImage, roof_2_uv)
            #
            #face = new Face -10, 10, 10, -10,  t1, t2
            #face.position.y = 10
            #face.position.z = 10
            #face.rotation.x = 30
            #face.rotation.y = 30
            #face.rotation.z = 30
            #scene.add face

            materials = [
                new Texture textureImage, roof_1_uv #top1
                new Texture textureImage, roof_2_uv #top2
                new Texture textureImage, wall_1_uv #bottom1
                new Texture textureImage, wall_2_uv #bottom2
                new Texture textureImage, wall_3_uv #wall1
                new Texture textureImage, wall_4_uv #wall2
                new Texture textureImage, wall_5_uv #wall3
                new Texture textureImage, wall_6_uv #wall4
                new Texture textureImage, wall_7_uv #wall5
                new Texture textureImage, wall_8_uv #wall6
            ]

            cube = new Cube 20, 20, 20, 1, 1, 1, materials
            cube.position.z = -50
            cube.rotation.z = 30
            scene.add cube

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
