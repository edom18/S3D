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

        photo = new Image()

        photo.onload = ->
            photoImage = photo
            create()

        photo.src = 'img/photo.jpg'
        #photo.src = 'http://jsrun.it/assets/7/j/g/k/7jgkb.jpg'

        camera = new Camera 40, aspect, 0.1, 10000
        camera.position.x = 0
        camera.position.y = 120
        camera.position.z = 320
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 50, 0
        camera.lookAtLock = true
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        #renderer.fog      = false
        #renderer.lighting = false
        #renderer.wireframe = true

        win.camera = camera

        create = ->
            plate1 = new Plate 500, 339, 10, 10, photoImage, photoImage
            #plate1 = new Plate 500, 339, 10, 10, new Color(255, 0, 0, 1), new Color(255, 0, 0, 1), new Color(0, 0, 255, 1), new Color(0, 0, 255, 1)
            plate1.rotation.z = 45
            plate1.position.set 0, 40, 0
            plate1.scale.set 0.1, 0.1, 0.1

            size = 200

            line1 = new Line(0, 0, -size / 2, 0, 0, size / 2, new Color(255, 0, 0, 0.3))
            line2 = new Line(-size / 2, 0, 0, size / 2, 0, 0, new Color(0, 255, 0, 0.3))
            line3 = new Line(0, size / 2, 0, 0, -size / 2, 0, new Color(0, 0, 255, 0.3))

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

            ambLight = new AmbientLight(0.1)
            dirLight = new DirectionalLight(0.8, (new Vector3(1, 0, 1)).normalize())
           
            scene.add ambLight
            scene.add dirLight

            scene.add plate1
            scene.add container
            scene.add line1
            scene.add line2
            scene.add line3

            angle = 0

            do _loop = ->
                angle = ((angle += 2) % 360)
                plate1.rotation.y = angle

                renderer.render scene, camera
                requestAnimFrame _loop

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

            moveX -= (prevX - pageX)# / 100
            moveY += (prevY - pageY)# / 100

            camera.position.y = moveY
            camera.position.x = moveX

            prevX = pageX
            prevY = pageY
            
            renderer.render scene, camera
        , false

        doc.addEventListener MOUSE_UP, (e) ->
            dragging = false
        , false

        # コントロール
        btnFog   = $('#fog')
        btnLight = $('#light')
        btnWire  = $('#wire')
        fog   = true
        light = true
        wire  = false

        btnFog.addEventListener MOUSE_DOWN, ->
            fog = !fog
            type = if fog then 'ON' else 'OFF'
            btnFog.value = "フォグ[#{type}]"
            renderer.fog = fog
        , false

        btnLight.addEventListener MOUSE_DOWN, ->
            light = !light
            type = if light then 'ON' else 'OFF'
            btnLight.value = "ライティング[#{type}]"
            renderer.lighting = light
        , false

        btnWire.addEventListener MOUSE_DOWN, ->
            wire = !wire
            type = if wire then 'ON' else 'OFF'
            btnWire.value = "ワイヤーフレーム[#{type}]"
            renderer.wireframe = wire
        , false

    doc.addEventListener 'DOMContentLoaded', init, false
