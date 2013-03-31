do (win = window, doc = window.document, exports = window) ->

    #Import
    {tan, cos, sin, PI} = Math

    DEG_TO_RAD = PI / 180
    ANGLE = PI * 2

    drawTriangle = (g, img, vertex_list, uv_list) ->

        width  = img.width
        height = img.height

        # 変換後のベクトル成分を計算
        _Ax = vertex_list[2] - vertex_list[0]
        _Ay = vertex_list[3] - vertex_list[1]
        _Bx = vertex_list[4] - vertex_list[0]
        _By = vertex_list[5] - vertex_list[1]

        # 裏面カリング
        # 頂点を結ぶ順が反時計回りの場合は「裏面」になり、その場合は描画をスキップ
        # 裏面かどうかの判定は外積を利用する
        # 判定は、3点の内、1-2点目と2-3点目との外積を計算し、結果がマイナスの場合は反時計回り。（外積の結果はZ軸に対しての数値）
        if(((_Ax * (vertex_list[5] - vertex_list[3])) - (_Ay * (vertex_list[4] - vertex_list[2]))) < 0)
            return

        # 変換前のベクトル成分を計算
        Ax = (uv_list[2] - uv_list[0]) * width
        Ay = (uv_list[3] - uv_list[1]) * height
        Bx = (uv_list[4] - uv_list[0]) * width
        By = (uv_list[5] - uv_list[1]) * height

        # move position from A(Ax, Ay) to _A(_Ax, _Ay)
        # move position from B(Ax, Ay) to _B(_Bx, _By)
        # A,Bのベクトルを、_A,_Bのベクトルに変換することが目的。
        # 変換を達成するには、a, b, c, dそれぞれの係数を導き出す必要がある。
        #
        #    ↓まずは公式。アフィン変換の移動以外を考える。
        #
        # _Ax = a * Ax + c * Ay
        # _Ay = b * Ax + d * Ay
        # _Bx = a * Bx + c * By
        # _By = b * Bx + d * By
        #
        #    ↓上記の公式を行列の計算で表すと以下に。
        #
        # |_Ax| = |Ax Ay||a|
        # |_Bx| = |Bx By||c|
        #
        #    ↓a, cについて求めたいのだから、左に掛けているものを「1」にする必要がある。
        #    　行列を1にするには、逆行列を左から掛ければいいので、両辺に逆行列を掛ける。（^-1は逆行列の意味）
        #
        # |Ax Ay|^-1 |_Ax| = |a|
        # |Bx By|    |_Bx| = |c|

        m = new M22()

        # 上記の
        # |Ax Ay|
        # |Bx By|
        # を生成
        m._11 = Ax; m._12 = Ay
        m._21 = Bx; m._22 = By

        # 逆行列を取得
        # 上記の
        # |Ax Ay|^-1
        # |Bx By|
        # を生成
        mi = m.getInvert()

        # 逆行列が存在しない場合はスキップ
        return if not mi

        a = mi._11 * _Ax + mi._12 * _Bx
        c = mi._21 * _Ax + mi._22 * _Bx

        b = mi._11 * _Ay + mi._12 * _By
        d = mi._21 * _Ay + mi._22 * _By

        # 各頂点座標を元に三角形を作り、それでクリッピング
        g.save()
        g.beginPath()
        g.moveTo(vertex_list[0], vertex_list[1])
        g.lineTo(vertex_list[2], vertex_list[3])
        g.lineTo(vertex_list[4], vertex_list[5])
        g.clip()

        g.transform(a, b, c, d,
            vertex_list[0] - (a * uv_list[0] * width + c * uv_list[1] * height),
            vertex_list[1] - (b * uv_list[0] * width + d * uv_list[1] * height))
        g.drawImage(img, 0, 0)
        g.restore()

# -------------------------------------------------------------------------------

    ###*
        Camera class
        @constructor
        @param {number} fov Field of view.
        @param {number} aspect Aspect ratio.
        @param {number} near Near clip.
        @param {number} far far clip.
        @param {Vector3} position Position vector.
    ###
    class Camera
        constructor: (@fov, @aspect, @near, @far, @position = new Vector3(0, 0, 20)) ->
            @viewMatrix = M44.translate @position
            @worldMatrix = new M44
            @projectionMatrix = new M44
            @updateProjectionMatrix()

        setWorld: (m) ->
            @worldMatrix = m

        getProjectionMatrix: ->
            tmp = M44.mul @viewMatrix, @projectionMatrix
            M44.mul @worldMatrix, tmp

        updateProjectionMatrix: ->
            @viewMatrix = M44.translate @position
            @projectionMatrix.perspectiveLH(@fov, @aspect, @near, @far)

# -------------------------------------------------------------------------------

    class Texture
        constructor: (@uv_data, @uv_list) ->

# -------------------------------------------------------------------------------

    class Mesh
        constructor: (@vertex, @texture) ->

# -------------------------------------------------------

    class Particle
        constructor: (@v, @sp = 1, @size = 1000, @r = 255, @g = 255, @b = 255) ->
            @vec = new Vector3 1, 0, 1

        update: ->
            p = new Quaternion 0, @v

            rad = @sp * DEG_TO_RAD

            # rad角の回転クォータニオンとその共役を生成
            q = makeRotatialQuaternion(rad, @vec)
            r = makeRotatialQuaternion(-rad, @vec)

            # Quaternionを以下のように計算
            # RPQ (RはQの共役）
            
            p = r.multiply p
            p = p.multiply q

            @v = p.v

# -------------------------------------------------------------------------------

    class Scene
        constructor: ->
            @materials = []

        add: (material) ->
            @materials.push material

        sort: (func) ->
            @materials.sort(func) if func

        each: (func) ->
            @materials.forEach(func) if func

# -------------------------------------------------------------------------------

    class Renderer
        constructor: (@cv) ->
            @g = cv.getContext '2d'
            @w = cv.width
            @h = cv.height

        render: (scene, camera) ->
            camera.updateProjectionMatrix()
            matProj = camera.getProjectionMatrix()

            @g.beginPath()
            @g.fillStyle = "rgba(0, 0, 0, 0.08)"
            @g.fillRect 0, 0, @w, @h

            @transformAndDraw matProj, scene.materials

        ###*
            Transform and draw.
            @param {M44} mat matrix.
            @param {Array} materials.
        ###
        transformAndDraw: (mat, materials) ->

            g = @g
            results = []

            for m in materials
                if m instanceof Mesh
                    vertex_list = material.vertex
                    uv_image = material.texture.uv_data
                    uv_list = material.texture.uv_list

                    @transformPoints(out_list, vertex_list, mat, @w, @h)
                    drawTriangle(g, uv_image, out_list, uv_list)

                else if m instanceof Particle
                    vertex_list = [m.v.x, m.v.y, m.v.z]
                    out_list = new Array(6)
                    @transformPoints2(out_list, vertex_list, mat, @w, @h)

                    x = out_list[0]
                    y = out_list[1]
                    w = out_list[2]
                    weight = m.size / w

                    continue if weight < 0

                    results.push
                        material: m
                        x: x
                        y: y
                        w: w
                        r: m.r
                        g: m.g
                        b: m.b
                        weight: weight

            results.sort (a, b) ->
                b.w - a.w

            for r in results
                g.save()
                g.fillStyle = "rgba(#{r.r}, #{r.g}, #{r.b}, #{r.weight})"
                g.beginPath()
                g.arc(r.x, r.y, r.weight, 0, ANGLE, true)
                g.closePath()
                g.fill()
                g.restore()


        ###*
            スクリーン座標変換
            Transform points
            @param {Array} out
            @param {Array} pts
            @param {M44} mat matrix
            @param {number} viewWidth
            @param {number} viewHeight

            計算された座標変換行列をスクリーンの座標系に変換するために計算する
            基本はスケーリング（&Y軸反転）と平行移動。
            行列で表すと
            w = width  / 2
            h = height / 2
            とすると
                        |w  0  0  0|
            M(screen) = |0 -h  0  0|
                        |0  0  1  0|
                        |w  h  0  1|
            以下の計算式で言うと、

            transformed_temp[0] *=  viewWidth
            transformed_temp[1] *= -viewHeight
            transformed_temp[0] +=  viewWidth  / 2
            transformed_temp[1] +=  viewHeight / 2

            となる。
        ###
        transformPoints: (out, pts, mat, viewWidth, viewHeight) ->

            len = pts.length
            transformed_temp = [0, 0, 0, 0]
            oi = 0

            _w = viewWidth  / 2
            _h = viewHeight / 2

            for i in [0...len] by 3
                mat.transVec3(transformed_temp, pts[i + 0], pts[i + 1], pts[i + 2])

                W = transformed_temp[3]
                transformed_temp[0] /= W
                transformed_temp[1] /= W
                transformed_temp[2] /= W

                transformed_temp[0] *=  _w
                transformed_temp[1] *= -_h

                transformed_temp[0] +=  _w
                transformed_temp[1] +=  _h

                out[oi++] = transformed_temp[0]
                out[oi++] = transformed_temp[1]


        transformPoints2: (out, pts, mat, viewWidth, viewHeight) ->

            transformed_temp = [0, 0, 0, 0]
            oi = 0

            _w = viewWidth  / 2
            _h = viewHeight / 2

            mat.transVec3(transformed_temp, pts[0], pts[1], pts[2])

            W = transformed_temp[3]
            transformed_temp[0] /= W
            transformed_temp[1] /= W
            transformed_temp[2] /= W

            transformed_temp[0] *=  _w
            transformed_temp[1] *= -_h

            transformed_temp[0] +=  _w
            transformed_temp[1] +=  _h

            out[0] = transformed_temp[0]
            out[1] = transformed_temp[1]
            out[2] = W

# -------------------------------------------------------------------------------

    ###*
        Vector3 class
        @constructor
        @param {number} x Position of x.
        @param {number} y Position of y.
        @param {number} z Position of z.
    ###
    class Vector3
        constructor: (@x = 0, @y = 0, @z = 0) ->
        zero: ->
            @x = @y = @z = 0;

        sub: (v) ->
            @x -= v.x
            @y -= v.y
            @z -= v.z
            return @

        add: (v) ->
            @x += v.x
            @y += v.y
            @z += v.z
            return @

        copy: (v) ->
            @x = v.x
            @y = v.y
            @z = v.z
            return @

        norm: ->
            Math.sqrt(@x * @x + @y * @y + @z * @z)

        normalize: ->
            nrm = @norm()
            if nrm isnt 0
                @x /= nrm
                @y /= nrm
                @z /= nrm

            return @


        multiply: (v) ->
            @x *= v.x
            @y *= v.y
            @z *= v.z

            return @

        #scalar multiplication
        multiplyScalar: (s) ->
            @x *= s
            @y *= s
            @z *= s
            return @

        multiplyVectors: (a, b) ->
            @x = a.x * b.x
            @y = a.y * b.y
            @z = a.z * b.z

        #dot product
        dot: (v) ->
            return @x * v.x + @y * v.y + @z * v.z

        cross: (v, w) ->

            return @crossVector(v, w) if w

            @x = (@y * v.z) - (@z * v.y)
            @y = (@z * v.x) - (@x * v.z)
            @z = (@x * v.y) - (@y * v.x)

            return @

        #cross product
        crossVector: (v, w) ->
            @x = (w.y * v.z) - (w.z * v.y)
            @y = (w.z * v.x) - (w.x * v.z)
            @z = (w.x * v.y) - (w.y * v.x)

            return @

        toString: ->
            "#{@x},#{@y},#{@z}"

# ---------------------------------------------------------------------

    class Quaternion
        constructor: (@t = 0, @v) ->

        set: (@t, @v) ->

        multiply: (A) ->
            return Quaternion.multiply @, A

        @multiply: (A, B) ->

            # Quaternionの掛け算の公式は以下。
            # ・は内積、×は外積、U, Vはともにベクトル。
            # ;の左が実部、右が虚部。
            # A = (a; U) 
            # B = (b; V) 
            # AB = (ab - U・V; aV + bU + U×V)

            Av = A.v
            Bv = B.v

            # 実部の計算
            d1 =  A.t * B.t
            d2 = -Av.x * Bv.x
            d3 = -Av.y * Bv.y
            d4 = -Av.z * Bv.z
            t = parseFloat((d1 + d2 + d3 + d4).toFixed(5))

            # 虚部xの計算
            d1 = (A.t * Bv.x) + (B.t * Av.x)
            d2 = (Av.y * Bv.z) - (Av.z * Bv.y)
            x = parseFloat((d1 + d2).toFixed(5))

            # 虚部yの計算
            d1 = (A.t * Bv.y) + (B.t * Av.y)
            d2 = (Av.z * Bv.x) - (Av.x * Bv.z)
            y = parseFloat((d1 + d2).toFixed(5))

            # 虚部zの計算
            d1 = (A.t * Bv.z) + (B.t * Av.z)
            d2 = (Av.x * Bv.y) - (Av.y * Bv.x)
            z = parseFloat((d1 + d2).toFixed(5))

            return new Quaternion t, new Vector3 x, y, z

    ###*
        Make rotation quaternion
        @param {number} radian.
        @param {Vector3} vector.
    ###
    makeRotatialQuaternion = (radian, vector) ->
    
        ret = new Quaternion
        ccc = 0
        sss = 0
        axis = new Vector3
        axis.copy vector

        norm = vector.norm()

        return ret if norm <= 0.0

        axis.normalize()

        ccc = cos(0.5 * radian)
        sss = sin(0.5 * radian)

        t = ccc
        axis.multiplyScalar sss

        ret.set t, axis

        return ret

# -----------------------------------------------------------

    ###*
        M44 class
        @constructor
        @param {boolean} cpy
    ###
    class M44
        constructor: (cpy) ->
            if (cpy) then @copy cpy else @ident()

        ident: ->

            # 以下のように初期化
            # |1 0 0 0|
            # |0 1 0 0|
            # |0 0 1 0|
            # |0 0 0 1|

            @_12 = @_13 = @_14 = 0
            @_21 = @_23 = @_24 = 0
            @_31 = @_32 = @_34 = 0
            @_41 = @_42 = @_43 = 0

            @_11 = @_22 = @_33 = @_44 = 1

            return @

        ###*
            Copy from `m`
            @param {M44} m
        ###
        copy: (m) ->
            @_11 = m._11; @_12 = m._12; @_13 = m._13; @_14 = m._14
            @_21 = m._21; @_22 = m._22; @_23 = m._23; @_24 = m._24
            @_31 = m._31; @_32 = m._32; @_33 = m._33; @_34 = m._34
            @_41 = m._41; @_42 = m._42; @_43 = m._43; @_44 = m._44

            return @

        ###*
            4x4の変換行列を対象の1x4行列[x, y, z, 1]に適用する
            1x4行列と4x4行列の掛け算を行う

                        |@_11 @_12 @_13 @_14|
            |x y z 1| x |@_21 @_22 @_23 @_24|
                        |@_31 @_32 @_33 @_34|
                        |@_41 @_42 @_43 @_44|

            @_4nは1x4行列の最後が1のため、ただ足すだけになる

            @param {Array.<number>} out
            @param {number} x
            @param {number} y
            @param {number} z
        ###
        transVec3: (out, x, y, z) ->
            out[0] = x * @_11 + y * @_21 + z * @_31 + @_41
            out[1] = x * @_12 + y * @_22 + z * @_32 + @_42
            out[2] = x * @_13 + y * @_23 + z * @_33 + @_43
            out[3] = x * @_14 + y * @_24 + z * @_34 + @_44

        perspectiveLH: (fov, aspect, near, far) ->
            tmp = M44.perspectiveLH(fov, aspect, near, far)
            @copy tmp

        @perspectiveLH: (fov, aspect, near, far) ->

            tmp = new M44

            ymax = near * tan(fov * DEG_TO_RAD * 0.5)
            ymin = -ymax
            xmin = ymin * aspect
            xmax = ymax * aspect

            vw = xmax - xmin
            vh = ymax - ymin

            zoomX = 2 * near / vw
            zoomY = 2 * near / vh

            # X軸方向のzoom値
            tmp._11 = zoomX
            tmp._12 = 0
            tmp._13 = 0
            tmp._14 = 0

            # Y軸方向のzoom値
            tmp._21 = 0
            tmp._22 = zoomY
            tmp._23 = 0
            tmp._24 = 0

            # W値用の値を算出
            #
            # Z座標は、ニアクリップ面では z/w = -1、
            # ファークリップ面では z/w = 1 になるように
            # バイアスされ、スケーリングされる。
            
            tmp._31 = 0
            tmp._32 = 0
            tmp._33 = far + near / (far - near)
            tmp._34 = 1

            tmp._41 = 0
            tmp._42 = 0
            tmp._43 = 2 * near * far / (near - far)
            tmp._44 = 0

            return tmp

        mul: (A) ->
            tmp = M44.mul(@, A)
            @copy tmp

            return @


        # multiplication
        # ABふたつの行列の掛け算した結果をthisに保存
        @mul: (A, B) ->

            tmp = new M44

            tmp._11 = A._11 * B._11 + A._12 * B._21 + A._13 * B._31 + A._14 * B._41
            tmp._12 = A._11 * B._12 + A._12 * B._22 + A._13 * B._32 + A._14 * B._42
            tmp._13 = A._11 * B._13 + A._12 * B._23 + A._13 * B._33 + A._14 * B._43
            tmp._14 = A._11 * B._14 + A._12 * B._24 + A._13 * B._34 + A._14 * B._44

            tmp._21 = A._21 * B._11 + A._22 * B._21 + A._23 * B._31 + A._24 * B._41
            tmp._22 = A._21 * B._12 + A._22 * B._22 + A._23 * B._32 + A._24 * B._42
            tmp._23 = A._21 * B._13 + A._22 * B._23 + A._23 * B._33 + A._24 * B._43
            tmp._24 = A._21 * B._14 + A._22 * B._24 + A._23 * B._34 + A._24 * B._44

            tmp._31 = A._31 * B._11 + A._32 * B._21 + A._33 * B._31 + A._34 * B._41
            tmp._32 = A._31 * B._12 + A._32 * B._22 + A._33 * B._32 + A._34 * B._42
            tmp._33 = A._31 * B._13 + A._32 * B._23 + A._33 * B._33 + A._34 * B._43
            tmp._34 = A._31 * B._14 + A._32 * B._24 + A._33 * B._34 + A._34 * B._44

            tmp._41 = A._41 * B._11 + A._42 * B._21 + A._43 * B._31 + A._44 * B._41
            tmp._42 = A._41 * B._12 + A._42 * B._22 + A._43 * B._32 + A._44 * B._42
            tmp._43 = A._41 * B._13 + A._42 * B._23 + A._43 * B._33 + A._44 * B._43
            tmp._44 = A._41 * B._14 + A._42 * B._24 + A._43 * B._34 + A._44 * B._44

            return tmp

        ###*
            @param {Vector3} v
        ###
        translate: (v) ->
            tmp = M44.translate v
            @mul tmp

            return @

        ###*
            translate by vector3
            @param {Vector3} v
        ###
        @translate: (v) ->

            tmp = new M44

            # As result like this
            # |1 0 0 0|
            # |0 1 0 0|
            # |0 0 1 0|
            # |x y z 1|

            tmp._11 = 1; tmp._12 = 0; tmp._13 = 0; tmp._14 = 0
            tmp._21 = 0; tmp._22 = 1; tmp._23 = 0; tmp._24 = 0
            tmp._31 = 0; tmp._32 = 0; tmp._33 = 1; tmp._34 = 0

            tmp._41 = v.x; tmp._42 = v.y; tmp._43 = v.z; tmp._44 = 1

            return tmp

        ###*
            @param {number} r Rotate X
        ###
        rotX: (r) ->

            # X軸による回転行列
            # |1       0      0 0|
            # |0  cos(r) sin(r) 0|
            # |0 -sin(r) cos(r) 0|
            # |0       0      0 1|

            @_22 = cos r
            @_23 = sin r
            @_32 = -@_23
            @_33 = @_22

            @_12 = @_13 = @_14 = @_21 = @_24 = @_31 = @_34 = @_41 = @_42 = @_43 = 0
            @_11 = @_44 = 1			

            return @

        ###*
            @param {number} r Rotate Y
        ###
        rotY: (r) ->

            # Y軸による回転行列
            # |cos(r)  0 -sin(r)  0|
            # |     0  1       0  0|
            # |sin(r)  0  cos(r)  0|
            # |     0  0       0  1|
            
            @_11 = cos r
            @_13 = -sin r
            @_31 = -@_13
            @_33 = @_11
            @_12 = @_14 = @_21 = @_23 = @_24 = @_32 = @_34 = @_41 = @_42 = @_43 = 0
            @_22 = @_44 = 1

            return @

        ###*
            @param {number} r Rotate Z
        ###
        rotZ: (r) ->

            # Z軸による回転行列
            # | cos(r) sin(r)  0  0|
            # |-sin(r) cos(r)  1  0|
            # |      0      0  0  0|
            # |      0      0  0  1|

            @_11 = cos r
            @_12 = sin r
            @_21 = -@_12
            @_22 = @_11
            @_13 = @_14 = @_23 = @_24 = @_31 = @_32 = @_34 = @_41 = @_42 = @_43 = 0
            @_33 = @_44 = 1

            return @

    ###*
        M22 class
        @constructor
    ###
    class M22
        constructor: ->
            # |1 0|
            # |0 1|
            # の行列で初期化
            @_11 = 1; @_12 = 0;
            @_21 = 0; @_22 = 1;

        ###*
            逆行列を生成
            
            [逆行列の公式]

            A = |a b|
                |c d|

            について、detA = ab - bc ≠0のときAの逆行列が存在する

            A^-1 = | d -b| * 1/ad-bc
                   |-c  a|
        ###
        getInvert: ->
            out = new M22()
            det = @_11 * @_22 - @_12 * @_21

            return null if 0.0001 > det > -0.0001

            out._11 =  @_22 / det
            out._22 =  @_11 / det
            out._12 = -@_12 / det
            out._21 = -@_21 / det

            return out

    exports.M44 = M44
    exports.Camera = Camera
    exports.Renderer = Renderer
    exports.Scene = Scene
    exports.Mesh = Mesh
    exports.Particle = Particle
    exports.Texture = Texture
    exports.Vector3 = Vector3
    exports.Quaternion = Quaternion

    
do (win = window, doc = window.document, exports = window) ->
 
    {sqrt, sin, cos, tan, PI, random} = Math

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
        renderer = new Renderer cv

        hw = cWidth / 2
        hh = cHeight / 2
        hf = FAR / 2

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
    

    base = 100
    startZoom = 0
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

        camera.setWorld(M44.mul((new M44()).rotY(rotY), (new M44()).rotX(rotX)))

        prevX = pageX
        prevY = pageY
        
        renderer.render scene, camera
    , false

    doc.addEventListener MOUSE_UP, (e) ->
        dragging = false
    , false

    doc.addEventListener 'DOMContentLoaded', init, false
