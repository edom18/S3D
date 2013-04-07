do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math
    {Object3D, Line, Color, AmbientLight, DirectionalLight, Plate, Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

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

        camera = new Camera 40, aspect, 0.1, 10000
        camera.position.x = 10
        camera.position.y = 50
        camera.position.z = 200
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 0, 0
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        renderer.fog      = false
        renderer.lighting = false
        #renderer.wireframe = true

        create = ->

            materials2 = [
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
                new Texture(video, [0, 0, 0, 1, 1, 0])
                new Texture(video, [0, 1, 1, 1, 1, 0])
            ]

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

            videoContainer.position.x = -videoWidth / 2
            videoContainer.position.y = videoHeight / 2
            videoContainer.scale.set(0.1, 0.1, 0.1)

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

                    face = new Face j * divW, i * divH, (j * divW + divW), -(i * divH + divH), new Texture(video, [uv_x1, uv_y1, uv_x2, uv_y2, uv_x4, uv_y4]), new Texture(video, [uv_x2, uv_y2, uv_x3, uv_y3, uv_x4, uv_y4])
                    videoContainer.add face
           
            scene.add ambLight
            scene.add dirLight

            scene.add videoContainer
            scene.add container
            scene.add line1
            scene.add line2
            scene.add line3

            do _loop = ->
                renderer.render scene, camera
                setTimeout _loop, 32

        video = doc.getElementById 'video'
        video.autoplay = true
        video.loop = true
        video.addEventListener 'canplaythrough', create, false

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
