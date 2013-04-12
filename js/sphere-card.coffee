do (win = window, doc = window.document, exports = window) ->

    #Import
    {atan2, random, tan, cos, sin, PI} = Math
    {PointLight, Face2, Object3D, Line, Color, AmbientLight, DirectionalLight, Plate, Face, Cube, Texture, Triangle, Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

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
    RAD_TO_DEG = 180 / PI

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
        camera.position.x = 0
        camera.position.y = 120
        camera.position.z = 320
        #camera.up = new Vector3 1, 0, 0
        camera.lookAt new Vector3 0, 50, 0
        camera.lookAtLock = true
        scene    = new Scene
        renderer = new Renderer cv, '#111'
        renderer.fogEnd = 10000
        #renderer.fog      = false
        #renderer.lighting = false
        #renderer.wireframe = true

        create = ->
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
            dirLight = new DirectionalLight(0.1, (new Vector3(1, 0, 1)).normalize())
            pointLight = new PointLight(1.0, 200, (new Vector3(0, 100, 0)))
            
            scene.add ambLight
            scene.add dirLight
            scene.add pointLight

            r = 100
            for s in [60...360] by 60
                for t in [60...180] by 20
                    _s = s * DEG_TO_RAD
                    _t = t * DEG_TO_RAD
                    x = r * cos(_s) * sin(_t)
                    z = r * sin(_s) * sin(_t)
                    y = r * cos(_t)

                    plate = new Plate(20, 20, 1, 1, new Color(255, 0, 0, 1), new Color(255, 0, 0, 1), new Color(0, 0, 255, 1), new Color(0, 0, 255, 1))
                    plate.position.set x, y, z
                    plate.rotation.z = t
                    plate.rotation.x = s
                    scene.add plate
                    scene.add new Particle(new Vector3(x, y, z), 500)

            scene.add container
            scene.add line1
            scene.add line2
            scene.add line3

            angle = 0

            dummy = new Particle(new Vector3(0, 0, 0), 5000)
            scene.add dummy
            do _loop = ->
                angle = ((angle += 1) % 360)
                #dirLight.direction.x = cos(angle * DEG_TO_RAD)
                #dirLight.direction.y = sin(angle * DEG_TO_RAD)
                dummy.position.x = cos(angle * DEG_TO_RAD) * 150
                dummy.position.y = sin(angle * DEG_TO_RAD) * 150
                pointLight.position.y = sin(angle * DEG_TO_RAD) * 150
                pointLight.position.x = cos(angle * DEG_TO_RAD) * 150

                renderer.render scene, camera
                requestAnimFrame _loop

        create()

        dragging = false
        prevX = 0
        prevY = 0

        # Events
        win.addEventListener 'mousewheel', (e) ->
            camera.position.z += (e.wheelDelta / 10)
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

            moveX -= (prevX - pageX) * 3
            moveY += (prevY - pageY) * 3

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
