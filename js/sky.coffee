do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math
    {Face2, Object3D, Line, Color, AmbientLight, DirectionalLight, Plate, Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    $ = (selector) ->
        doc.querySelector selector

    requestAnimFrame = do ->
        return win.requestAnimationFrame or
               win.webkitRequestAnimationFrame or
               win.mozRequestAnimationFrame or
               win.msRequestAnimationFrame or
               (callback) ->
                   setTimeout callback, 16

    DEG_TO_RAD = PI / 180

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

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

        size = 1024
        hSize = size * 0.5

        camera = new Camera 60, aspect, 1, 10000
        camera.position.set 0, 0, 10
        camera.lookAt new Vector3 0, 0, 0
        camera.lookAtLock = true
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        renderer.fog      = false
        #renderer.lighting = false
        #renderer.wireframe = true

        create = ->

            frontImg = $('#texture > .front')
            backImg = $('#texture > .back')
            leftImg = $('#texture > .left')
            rightImg = $('#texture > .right')
            topImg = $('#texture > .top')
            bottomImg = $('#texture > .bottom')

            div = 3

            #front
            face1 = new Face2 size, size, div, div, frontImg, frontImg
            face1.position.z = -hSize
            scene.add face1

            #right
            face2 = new Face2 size, size, div, div, rightImg, rightImg
            face2.rotation.y = -90
            face2.position.x = hSize
            scene.add face2

            #left
            face3 = new Face2 size, size, div, div, leftImg, leftImg
            face3.rotation.y = 90
            face3.position.x = -hSize
            scene.add face3

            #back
            face4 = new Face2 size, size, div, div, backImg, backImg
            face4.rotation.y = 180
            face4.position.z = hSize
            scene.add face4

            #bottom
            face5 = new Face2 size, size, div, div, bottomImg, bottomImg
            face5.rotation.x = -90
            face5.position.y = -hSize
            scene.add face5

            #top
            face6 = new Face2 size, size, div, div, topImg, topImg
            face6.rotation.x = 90
            face6.position.y = hSize
            scene.add face6

            container = new Object3D
            container.position.x = -(size * 0.5)
            container.position.z = -(size * 0.5)

            for i in [0..(size / 10)]
                z = i * 10
                line = new Line(0, 0, z, size, 0, z, new Color(255, 255, 255, 0.3))
                container.add line

            for i in [0..(size / 10)]
                x = i * 10
                line = new Line(x, 0, 0, x, 0, size, new Color(255, 255, 255, 0.3))
                container.add line

                #scene.add container

            ambLight = new AmbientLight(1.0)
            scene.add ambLight

            # Rendering start
            renderer.render scene, camera

        create()

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

        moveX = camera.position.x
        moveY = camera.position.y
        doc.addEventListener MOUSE_MOVE, (e) ->
            return if dragging is false

            pageX = if isTouch then e.touches[0].pageX else e.pageX
            pageY = if isTouch then e.touches[0].pageY else e.pageY

            moveX -= (prevX - pageX) % 360
            moveY += (prevY - pageY)

            limit = 300
            moveY = limit if moveY > limit
            moveY = -limit if moveY < -limit

            camera.position.y = moveY
            camera.position.x = sin(moveX * DEG_TO_RAD) * 500 * 0.5
            camera.position.z = cos(moveX * DEG_TO_RAD) * 500 * 0.5

            prevX = pageX
            prevY = pageY
            
            renderer.render scene, camera
        , false

        doc.addEventListener MOUSE_UP, (e) ->
            dragging = false
        , false

    doc.addEventListener 'DOMContentLoaded', init, false
