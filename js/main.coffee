do (win = window, doc = window.document, exports = window) ->
 
    {sqrt, sin, cos, tan, PI, random} = Math
    {Matrix4, Camera, Renderer, Scene, Vector3, Particle} = window.S3D

    isTouch = 'ontouchstart' of window
    MOUSE_DOWN = if isTouch then 'touchstart' else 'mousedown'
    MOUSE_MOVE = if isTouch then 'touchmove' else 'mousemove'
    MOUSE_UP   = if isTouch then 'touchend' else 'mouseup'

    requestAnimFrame = do ->
        return win.requestAnimationFrame or
               win.mozRequestAnimationFrame or
               win.msRequestAnimationFrame or
               (callback, element) ->
                   win.setTimeout callback, 16

    camera = null
    scene = null
    renderer = null

    particles = []
    cv  = doc.querySelector '#canvas'
    ctx = cv.getContext '2d'
    cWidth = cv.width = win.innerWidth
    cHeight = cv.height = win.innerHeight
    FAR = 2000

    rotX = 0
    rotY = 0
    rotZ = 0

    dragging = false
    prevX = 0
    prevY = 0

# -------------------------------------------------------

    init = ->

        camera = new Camera 90, cWidth / cHeight, 1, FAR
        camera.position.z = 1000
        scene = new Scene
        renderer = new Renderer cv, 'rgba(0, 0, 0, 0.08)'

        hw = cWidth / 2
        hh = cHeight / 2
        hf = FAR / 2

        base = 100
        startZoom = 0

        v = new Vector3 0, 0, 0
        particle = new Particle v, 0, 10000, 200, 200, 0
        particles[0] = particle
        scene.add particle

        for i in [1...300]
            x = ~~(random() * cWidth) - hw
            y = ~~(random() * cHeight) - hh
            z = ~~(random() * FAR) - hf
            r = ~~(random() * 255)
            g = ~~(random() * 255)
            b = ~~(random() * 255)
            v = new Vector3 x, y, z
            size = (~~(random() * FAR)) + 5
            sp = random() * 2 + 0.1

            particle = new Particle v, sp, size, r, g, b
            particles[i] = particle
            scene.add particle

        ctx.fillStyle = '#000'
        ctx.fillRect(0, 0, cWidth, cHeight)

        draw()

    draw = ->
        for p in particles
            p.update()

        renderer.render scene, camera

        requestAnimFrame draw

    # Events
    win.addEventListener 'mousewheel', (e) ->
        camera.position.z -= ~~(e.wheelDelta / 10)
        renderer.render scene, camera

        e.preventDefault()
    , false
    

    document.addEventListener 'gesturechange', (e) ->
        num =  e.scale * base - base
        camera.position.z = startZoom - num
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

        camera.setWorld(Matrix4.multiply((new Matrix4()).rotY(rotY), (new Matrix4()).rotX(rotX)))

        prevX = pageX
        prevY = pageY
        
        renderer.render scene, camera
    , false

    doc.addEventListener MOUSE_UP, (e) ->
        dragging = false
    , false

    doc.addEventListener 'DOMContentLoaded', init, false
