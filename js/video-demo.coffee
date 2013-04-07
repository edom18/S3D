do (win = window, doc = window.document, exports = window) ->

    #Import
    {random, tan, cos, sin, PI} = Math
    {Object3D, Line, Color, AmbientLight, DirectionalLight, Plate, Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

    init = ->

        cv  = doc.getElementById 'canvas'
        ctx = cv.getContext '2d'
        w = cv.width  = win.innerWidth
        h = cv.height = win.innerHeight
        aspect = w / h

        camera = new Camera 60, aspect, 0.1, 10000
        camera.position.x = 200
        camera.position.y = 120
        camera.position.z = 280
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 100, 0
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        #renderer.fog      = false
        #renderer.lighting = false
        #renderer.wireframe = true

        initialized = false

        create = ->

            return if initialized
            initialized = true

            line1 = new Line(0, 0, -200, 0, 0, 200, new Color(255, 0, 0, 0.3))
            line2 = new Line(-200, 0, 0, 200, 0, 0, new Color(0, 255, 0, 0.3))
            line3 = new Line(0, 200, 0, 0, -200, 0, new Color(0, 0, 255, 0.3))

            size = 300
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
            dirLight = new DirectionalLight(0.8, (new Vector3(-1, 1, 1)).normalize())

            videoContainer = new Object3D

            div = 5
            videoWidth  = video.videoWidth
            videoHeight = video.videoHeight
            divW = videoWidth  / div
            divH = videoHeight / div

            videoContainer.position.x = -videoWidth / (2 / 0.7)
            videoContainer.position.y = videoHeight * 0.7
            videoContainer.scale.set(0.7, 0.7, 0.7)

            facies = []
            for i in [0...div]
                for j in [0...div]
                    uv_x1 = ((j + 0) * divW) / videoWidth
                    uv_y1 = ((i + 0) * divH) / videoHeight
                    uv_x2 = ((j + 0) * divW) / videoWidth
                    uv_y2 = ((i + 1) * divH) / videoHeight
                    uv_x3 = ((j + 1) * divW) / videoWidth
                    uv_y3 = ((i + 1) * divH) / videoHeight
                    uv_x4 = ((j + 1) * divW) / videoWidth
                    uv_y4 = ((i + 0) * divH) / videoHeight

                    face = new Face 0, 0, divW, -divH,
                        new Texture(video, [uv_x1, uv_y1, uv_x2, uv_y2, uv_x4, uv_y4]),
                        new Texture(video, [uv_x2, uv_y2, uv_x3, uv_y3, uv_x4, uv_y4])
                    face.position.set(j * divW, -(i * divH), ~~(random() * -500))
                    face.position.originalZ = face.position.z
                    #face.position.set(j * divW, -(i * divH), 0)
                    facies.push face
                    videoContainer.add face
           
            scene.add ambLight
            scene.add dirLight

            scene.add videoContainer
            scene.add container
            #scene.add line1
            #scene.add line2
            #scene.add line3

            DEG_TO_RAD = PI / 180
            angle = 0
            do _loop = ->
                angle = (++angle % 360)

                for f in facies
                    f.position.z = f.position.originalZ + (sin(angle * DEG_TO_RAD) * f.position.originalZ)

                renderer.render scene, camera
                setTimeout _loop, 32

        video = doc.getElementById 'video'
        video.autoplay = true
        video.loop = true
        video.addEventListener 'canplaythrough', create, false
        video.addEventListener 'canplay', create, false
        video.addEventListener 'loadeddata', create, false

        # -----------------------------------------------------------------

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

    doc.addEventListener 'DOMContentLoaded', init, false
