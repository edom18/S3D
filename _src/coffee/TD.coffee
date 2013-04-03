do (win = window, doc = window.document, exports = window.S3D or (window.S3D = {})) ->

    #Import
    {sqrt, tan, cos, sin, PI} = Math

    DEG_TO_RAD = PI / 180
    ANGLE = PI * 2

    drawTriangle = (g, img, vertex_list, uv_list, vw, vh) ->

        width  = img.width
        height = img.height

        hvw = vw * 0.5
        hvh = vh * 0.5

        #x1 = vertex_list[0]; x2 = vertex_list[3]; x3 = vertex_list[6];
        #y1 = vertex_list[1]; y2 = vertex_list[4]; y3 = vertex_list[7];
        #z1 = vertex_list[2]; z2 = vertex_list[5]; z3 = vertex_list[8];

        x1 = vertex_list[0] *  hvw + hvw
        y1 = vertex_list[1] * -hvh + hvh
        z1 = vertex_list[2]
        x2 = vertex_list[3] *  hvw + hvw
        y2 = vertex_list[4] * -hvh + hvh
        z2 = vertex_list[5]
        x3 = vertex_list[6] *  hvw + hvw
        y3 = vertex_list[7] * -hvh + hvh
        z3 = vertex_list[8]

        # 変換後のベクトル成分を計算
        _Ax = x2 - x1
        _Ay = y2 - y1
        _Bx = x3 - x1
        _By = y3 - y1

        # 裏面カリング
        # 頂点を結ぶ順が反時計回りの場合は「裏面」になり、その場合は描画をスキップ
        # 裏面かどうかの判定は外積を利用する
        # 判定は、3点の内、1-2点目と2-3点目との外積を計算し、結果がマイナスの場合は反時計回り。（外積の結果はZ軸に対しての数値）
        return if(((_Ax * (y3 - y2)) - (_Ay * (x3 - x2))) < 0)

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

        # 上記の
        # |Ax Ay|
        # |Bx By|
        # を生成
        m = new Matrix2(Ax, Ay, Bx, By)
        me = m.elements

        # 逆行列を取得
        # 上記の
        # |Ax Ay|^-1
        # |Bx By|
        # を生成
        mi = m.getInvert()
        mie = mi.elements

        # 逆行列が存在しない場合はスキップ
        return if not mi

        a = mie[0] * _Ax + mie[2] * _Bx
        c = mie[1] * _Ax + mie[3] * _Bx
        b = mie[0] * _Ay + mie[2] * _By
        d = mie[1] * _Ay + mie[3] * _By

        # 各頂点座標を元に三角形を作り、それでクリッピング
        g.save()
        g.beginPath()
        g.moveTo(x1, y1)
        g.lineTo(x2, y2)
        g.lineTo(x3, y3)
        g.clip()

        g.transform(a, b, c, d,
            x1 - (a * uv_list[0] * width + c * uv_list[1] * height),
            y1 - (b * uv_list[0] * width + d * uv_list[1] * height))
        g.drawImage(img, 0, 0)
        g.restore()

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

        subVectors: (a, b) ->
            @x = a.x - b.x
            @y = a.y - b.y
            @z = a.z - b.z
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
            sqrt(@x * @x + @y * @y + @z * @z)

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

        applyMatrix4: (m) ->
            e = m.elements

            x = @x
            y = @y
            z = @z

            @x = e[0] * x + e[4] * y + e[8]  * z + e[12]
            @x = e[1] * x + e[5] * y + e[9]  * z + e[13]
            @x = e[2] * x + e[5] * y + e[10] * z + e[14]

            return @

        ###*
            射影投影座標変換

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
        applyProjection: (m) ->

            x = @x
            y = @y
            z = @z

            e = m.elements

            #Perspective divide
            w = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15])

            @x = (e[0] * x + e[4] * y + e[8]  * z + e[12]) * w
            @y = (e[1] * x + e[5] * y + e[9]  * z + e[13]) * w
            @z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w

            return @

        clone: ->
            vec3 = new Vector3
            vec3.copy @
            return vec3

        toArray: ->
            return [@x, @y, @z]

        toString: ->
            "#{@x},#{@y},#{@z}"


# -------------------------------------------------------------------

    ###*
        Matrix2 class
        @constructor
    ###
    class Matrix2
        constructor: (m11 = 1, m12 = 0, m21 = 0, m22 = 1) ->

            @elements = te = new Float32Array 4

            # |1 0|
            # |0 1|
            # ----------
            # |m11 m12|
            # |m21 m22|
            # の行列で初期化

            te[0] = m11; te[2] = m12;
            te[1] = m21; te[3] = m22;

        ###*
            逆行列を生成
            
            [逆行列の公式]

            A = |a b|
                |c d|

            について、detA = ad - bc ≠0のときAの逆行列が存在する

            A^-1 = | d -b| * 1 / detA
                   |-c  a|
        ###
        getInvert: ->
            out = new Matrix2()
            oe  = out.elements
            te  = @elements

            det = te[0] * te[3] - te[2] * te[1]

            return null if 0.0001 > det > -0.0001

            oe[0] =  te[3] / det
            oe[1] = -te[1] / det
            oe[2] = -te[2] / det
            oe[3] =  te[0] / det

            return out

# -----------------------------------------------------------

    ###*
        Matrix4 class
        @constructor
        @param {boolean} cpy
    ###
    class Matrix4
        constructor: (cpy) ->
            @elements = new Float32Array 16
            if (cpy) then @copy cpy else @identity()

        identity: ->

            # 以下のように初期化
            # |1 0 0 0|
            # |0 1 0 0|
            # |0 0 1 0|
            # |0 0 0 1|
            #
            # |m11 m12 m13 m14|
            # |m21 m22 m23 m24|
            # |m31 m32 m33 m34|
            # |m41 m42 m43 m44|
            #
            # OpenGLでは以下の一次元配列となる（縦横に注意）
            # |m[0] m[4] m[8]  m[12]|
            # |m[1] m[5] m[9]  m[13]|
            # |m[2] m[6] m[10] m[14]|
            # |m[3] m[7] m[11] m[15]|

            te = @elements

            te[0] = 1; te[4] = 0; te[8]  = 0; te[12] = 0;
            te[1] = 0; te[5] = 1; te[9]  = 0; te[13] = 0;
            te[2] = 0; te[6] = 0; te[10] = 1; te[14] = 0;
            te[3] = 0; te[7] = 0; te[11] = 0; te[15] = 1;

            return @


        getInvert: ->
            out = new Matrix4
            oe  = out.elements
            te  = @elements

            a11 = te[0]; a12 = te[4]; a13 = te[8];  a14 = te[12];
            a21 = te[1]; a22 = te[5]; a23 = te[9];  a24 = te[13];
            a31 = te[2]; a32 = te[6]; a33 = te[10]; a34 = te[14];
            a41 = te[3]; a42 = te[7]; a43 = te[11]; a44 = te[15];

            det = (a11 * a22 * a33 * a44
            + a11 * a23 * a34 * a42
            + a11 * a24 * a32 * a43
            + a12 * a21 * a34 * a43
            + a12 * a23 * a31 * a44
            + a12 * a24 * a33 * a41
            + a13 * a21 * a32 * a44
            + a13 * a22 * a34 * a41
            + a13 * a24 * a31 * a42
            + a14 * a21 * a33 * a42
            + a14 * a22 * a31 * a43
            + a14 * a23 * a32 * a41
            - a11 * a22 * a34 * a43
            - a11 * a23 * a32 * a44
            - a11 * a24 * a33 * a42
            - a12 * a21 * a33 * a44
            - a12 * a23 * a34 * a41
            - a12 * a24 * a31 * a43
            - a13 * a21 * a34 * a42
            - a13 * a22 * a31 * a44
            - a13 * a24 * a32 * a41
            - a14 * a21 * a32 * a43
            - a14 * a22 * a33 * a41
            - a14 * a23 * a31 * a42)

            return null if 0.0001 > det > -0.0001

            b11 = ((a22 * a33 * a44) + (a23 * a34 * a42) + (a24 * a32 * a43) - (a22 * a34 * a43) - (a23 * a32 * a44) - (a24 * a33 * a42)) / det
            b12 = ((a12 * a34 * a43) + (a13 * a32 * a44) + (a14 * a33 * a42) - (a12 * a33 * a44) - (a13 * a34 * a42) - (a14 * a32 * a43)) / det
            b13 = ((a12 * a23 * a44) + (a13 * a24 * a42) + (a14 * a22 * a43) - (a12 * a24 * a43) - (a13 * a22 * a44) - (a14 * a23 * a42)) / det
            b14 = ((a12 * a24 * a33) + (a13 * a22 * a34) + (a14 * a23 * a32) - (a12 * a23 * a34) - (a13 * a24 * a32) - (a14 * a22 * a33)) / det

            b21 = ((a21 * a34 * a43) + (a23 * a31 * a44) + (a24 * a33 * a41) - (a21 * a33 * a44) - (a23 * a34 * a41) - (a24 * a31 * a43)) / det
            b22 = ((a11 * a33 * a44) + (a13 * a34 * a41) + (a14 * a31 * a43) - (a11 * a34 * a43) - (a13 * a31 * a44) - (a14 * a33 * a41)) / det
            b23 = ((a11 * a24 * a43) + (a13 * a21 * a44) + (a14 * a23 * a41) - (a11 * a23 * a44) - (a13 * a24 * a41) - (a14 * a21 * a43)) / det
            b24 = ((a11 * a23 * a34) + (a13 * a24 * a31) + (a14 * a21 * a33) - (a11 * a24 * a33) - (a13 * a21 * a34) - (a14 * a23 * a31)) / det

            b31 = ((a21 * a32 * a44) + (a22 * a34 * a41) + (a24 * a31 * a42) - (a21 * a34 * a42) - (a22 * a31 * a44) - (a24 * a32 * a41)) / det
            b32 = ((a11 * a34 * a42) + (a12 * a31 * a44) + (a14 * a32 * a41) - (a11 * a32 * a44) - (a12 * a34 * a41) - (a14 * a31 * a42)) / det
            b33 = ((a11 * a22 * a44) + (a12 * a24 * a41) + (a14 * a21 * a42) - (a11 * a24 * a42) - (a12 * a21 * a44) - (a14 * a22 * a41)) / det
            b34 = ((a11 * a24 * a32) + (a12 * a21 * a34) + (a14 * a22 * a31) - (a11 * a22 * a34) - (a12 * a24 * a31) - (a14 * a21 * a32)) / det

            b41 = ((a21 * a33 * a42) + (a22 * a31 * a43) + (a23 * a32 * a41) - (a21 * a32 * a43) - (a22 * a33 * a41) - (a23 * a31 * a42)) / det
            b42 = ((a11 * a32 * a43) + (a12 * a33 * a41) + (a13 * a31 * a42) - (a11 * a33 * a42) - (a12 * a31 * a43) - (a13 * a32 * a41)) / det
            b43 = ((a11 * a23 * a42) + (a12 * a21 * a43) + (a13 * a22 * a41) - (a11 * a22 * a43) - (a12 * a23 * a41) - (a13 * a21 * a42)) / det
            b44 = ((a11 * a22 * a33) + (a12 * a23 * a31) + (a13 * a21 * a32) - (a11 * a23 * a32) - (a12 * a21 * a33) - (a13 * a22 * a31)) / det

            oe[0] = b11; oe[4] = b12; oe[8]  = b13; oe[12] = b14;
            oe[1] = b21; oe[5] = b22; oe[9]  = b23; oe[13] = b24;
            oe[2] = b31; oe[6] = b32; oe[10] = b33; oe[14] = b34;
            oe[3] = b41; oe[7] = b42; oe[11] = b43; oe[15] = b44;

            return out


        ###*
            Copy from `m`
            @param {Matrix4} m
        ###
        copy: (m) ->

            te = @elements
            me = m.elements

            te[0] = me[0]; te[4] = me[4]; te[8]  = me[8];  te[12] = me[12];
            te[1] = me[1]; te[5] = me[5]; te[9]  = me[9];  te[13] = me[13];
            te[2] = me[2]; te[6] = me[6]; te[10] = me[10]; te[14] = me[14];
            te[3] = me[3]; te[7] = me[7]; te[11] = me[11]; te[15] = me[15];

            return @

        makeFrustum: (left, right, bottom, top, near, far) ->

            te = @elements
            vw = right - left
            vh = top - bottom

            x = 2 * near / vw
            y = 2 * near / vh

            z = - (far + near) / (far - near)
            w = - (2 * near * far) / (far - near)

            #a = (right + left) / (right - left)
            #b = (top + bottom) / (top - bottom)

            # W値用の値を算出
            #
            # Z座標は、ニアクリップ面では z/w = -1、
            # ファークリップ面では z/w = 1 になるように
            # バイアスされ、スケーリングされる。
            te[0]  = x; te[4] = 0; te[8]  =  0; te[12] = 0;
            te[1]  = 0; te[5] = y; te[9]  =  0; te[13] = 0;
            te[2]  = 0; te[6] = 0; te[10] =  z; te[14] = w;
            te[3]  = 0; te[7] = 0; te[11] = -1; te[15] = 0;

            return @


        perspectiveLH: (fov, aspect, near, far) ->
            tmp = Matrix4.perspectiveLH(fov, aspect, near, far)
            @copy tmp

        @perspectiveLH: (fov, aspect, near, far) ->

            tmp = new Matrix4
            te  = tmp.elements

            ymax = near * tan(fov * DEG_TO_RAD * 0.5)
            ymin = -ymax
            xmin = ymin * aspect
            xmax = ymax * aspect

            return tmp.makeFrustum xmin, xmax, ymin, ymax, near, far

        multiply: (A) ->
            tmp = Matrix4.multiply(@, A)
            @copy tmp

            return @


        # multiplication
        # ABふたつの行列の掛け算した結果をthisに保存
        @multiply: (A, B) ->

            ae = A.elements
            be = B.elements

            A11 = ae[0]; A12 = ae[4]; A13 = ae[8];  A14 = ae[12];
            A21 = ae[1]; A22 = ae[5]; A23 = ae[9];  A24 = ae[13];
            A31 = ae[2]; A32 = ae[6]; A33 = ae[10]; A34 = ae[14];
            A41 = ae[3]; A42 = ae[7]; A43 = ae[11]; A44 = ae[15];

            B11 = be[0]; B12 = be[4]; B13 = be[8];  B14 = be[12];
            B21 = be[1]; B22 = be[5]; B23 = be[9];  B24 = be[13];
            B31 = be[2]; B32 = be[6]; B33 = be[10]; B34 = be[14];
            B41 = be[3]; B42 = be[7]; B43 = be[11]; B44 = be[15];

            tmp = new Matrix4
            te  = tmp.elements

            te[0]  = A11 * B11 + A12 * B21 + A13 * B31 + A14 * B41
            te[4]  = A11 * B12 + A12 * B22 + A13 * B32 + A14 * B42
            te[8]  = A11 * B13 + A12 * B23 + A13 * B33 + A14 * B43
            te[12] = A11 * B14 + A12 * B24 + A13 * B34 + A14 * B44

            te[1]  = A21 * B11 + A22 * B21 + A23 * B31 + A24 * B41
            te[5]  = A21 * B12 + A22 * B22 + A23 * B32 + A24 * B42
            te[9]  = A21 * B13 + A22 * B23 + A23 * B33 + A24 * B43
            te[13] = A21 * B14 + A22 * B24 + A23 * B34 + A24 * B44

            te[2]  = A31 * B11 + A32 * B21 + A33 * B31 + A34 * B41
            te[6]  = A31 * B12 + A32 * B22 + A33 * B32 + A34 * B42
            te[10] = A31 * B13 + A32 * B23 + A33 * B33 + A34 * B43
            te[14] = A31 * B14 + A32 * B24 + A33 * B34 + A34 * B44

            te[3]  = A41 * B11 + A42 * B21 + A43 * B31 + A44 * B41
            te[7]  = A41 * B12 + A42 * B22 + A43 * B32 + A44 * B42
            te[11] = A41 * B13 + A42 * B23 + A43 * B33 + A44 * B43
            te[15] = A41 * B14 + A42 * B24 + A43 * B34 + A44 * B44

            return tmp

        ###*
            Multiply Matrices
            A, Bふたつの行列の掛け算した結果をthisに保存
            @param {Matrix4} A.
            @param {Matrix4} B.
        ###
        multiplyMatrices: (A, B) ->
            tmp = Matrix4.multiply A, B
            @copy tmp

            return @

        ###*
            @param {Vector3} v
        ###
        translate: (v) ->

            te = @elements
            x = v.x
            y = v.y
            z = v.z

            te[12] = te[0] * x + te[4] * y + te[8]  * z + te[12]
            te[13] = te[1] * x + te[5] * y + te[9]  * z + te[13]
            te[14] = te[2] * x + te[6] * y + te[10] * z + te[14]
            te[15] = te[3] * x + te[7] * y + te[11] * z + te[15]

            return @

        ###*
            @param {Vector3} eye
            @param {Vector3} target
            @param {Vector3} up
        ###
        lookAt: do ->
            #カメラに対してのX, Y, Z軸をそれぞれ定義
            x = new Vector3
            y = new Vector3
            z = new Vector3

            return (eye, target, up) ->

                te = @elements

                z.subVectors(eye, target).normalize()
                x.crossVector(up, z).normalize()
                y.crossVector(z, x).normalize()

                tx = eye.dot x
                ty = eye.dot y
                tz = eye.dot z

                te[0] = x.x; te[4] = x.y; te[8]  = x.z; te[12] = -tx;
                te[1] = y.x; te[5] = y.y; te[9]  = y.z; te[13] = -ty;
                te[2] = z.x; te[6] = z.y; te[10] = z.z; te[14] = -tz;
                #te[3] =  tx; te[7] =  ty; te[11] =  tz;

                return @

        ###*
            @param {number} r Rotate X
        ###
        rotationX: (r) ->

            # OpenGLのX軸による回転行列
            # |1       0      0  0|
            # |0  cos(r) -sin(r) 0|
            # |0  sin(r)  cos(r) 0|
            # |0       0      0  1|

            te = @elements
            c = cos r
            s = sin r

            te[0] = 1; te[4] = 0; te[8]  =  0; te[12] = 0;
            te[1] = 0; te[5] = c; te[9]  = -s; te[13] = 0;
            te[2] = 0; te[6] = s; te[10] =  c; te[14] = 0;
            te[3] = 0; te[7] = 0; te[11] =  0; te[15] = 1;

            return @

        ###*
            @param {number} r Rotate Y
        ###
        rotationY: (r) ->

            # OpenGLのY軸による回転行列
            # | cos(r)  0  sin(r)  0|
            # |      0  1       0  0|
            # |-sin(r)  0  cos(r)  0|
            # |      0  0       0  1|
            
            te = @elements
            c = cos r
            s = sin r

            te[0] =  c; te[4] = 0; te[8]  = s; te[12] = 0;
            te[1] =  0; te[5] = 1; te[9]  = 0; te[13] = 0;
            te[2] = -s; te[6] = 0; te[10] = c; te[14] = 0;
            te[3] =  0; te[7] = 0; te[11] = 0; te[15] = 1;

            return @

        ###*
            @param {number} r Rotate Z
        ###
        rotationZ: (r) ->

            # OpenGLのZ軸による回転行列
            # | cos(r) -sin(r)  0  0|
            # | sin(r)  cos(r)  0  0|
            # |      0      0   1  0|
            # |      0      0   0  1|

            te = @elements
            c = cos r
            s = sin r

            te[0] = c; te[4] = -s; te[8]  = 0; te[12] = 0;
            te[1] = s; te[5] =  c; te[9]  = 0; te[13] = 0;
            te[2] = 0; te[6] =  0; te[10] = 1; te[14] = 0;
            te[3] = 0; te[7] =  0; te[11] = 0; te[15] = 1;

            return @

        clone: ->
            tmp = new Matrix4
            tmp.copy @
            return tmp

# -------------------------------------------------------------------------------

    class Object3D
        constructor: ->
            @parent = null
            @children = []
            @position = new Vector3
            @rotation = new Vector3
            @scale = new Vector3 1, 1, 1
            @up    = new Vector3 0, 1, 0

            @matrix = new Matrix4
            @matrixWorld = new Matrix4

            @updateMatrix()

        updateTranslate: do ->
            tm = new Matrix4

            return ->
                return tm.clone().translate(@position)

        updateRotation: do ->
            rmx = new Matrix4
            rmy = new Matrix4
            rmz = new Matrix4

            return ->
                x = @rotation.x * DEG_TO_RAD
                y = @rotation.y * DEG_TO_RAD
                z = @rotation.z * DEG_TO_RAD

                tmp = new Matrix4
                rmx.rotationX x
                rmy.rotationY y
                rmz.rotationZ z

                tmp.multiplyMatrices rmx, rmy
                tmp.multiply rmz

                return tmp


        updateMatrix: ->
            tmp = @updateRotation()
            tmp.multiply @updateTranslate()
            @matrix.copy tmp

            c.updateMatrix() for c in @children

        updateMatrixWorld: ->
            if not @parent
                @matrixWorld.copy @matrix
            else
                @matrixWorld.multiplyMatrices @parent.matrixWorld, @matrix

            c.updateMatrixWorld() for c in @children

        localToWorld: (vector) ->
            return vector.applyMatrix4 @matrixWorld

        add: (object) ->
            return null if @ is object

            object.parent?.remove object

            @children.push object
            object.parent = @

        remove: (object) ->
            return null if @ is object

            index = @children.indexOf object

            return null if index is -1

            ret = @children.splice index, 1

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
    class Camera extends Object3D
        constructor: (@fov, @aspect, @near, @far, @position = new Vector3(0, 0, 20)) ->
            super

            @viewMatrix = new Matrix4
            @projectionMatrix = new Matrix4
            #@updateProjectionMatrix()

        setWorld: (m) ->
            @matrixWorld = m

        getProjectionMatrix: ->
            tmp = Matrix4.multiply @projectionMatrix, @viewMatrix
            Matrix4.multiply tmp, @matrixWorld

        updateProjectionMatrix: ->
            @lookAt()
            @projectionMatrix.perspectiveLH(@fov, @aspect, @near, @far)

        lookAt: do ->

            m1 = new Matrix4

            return (vector) ->
                @vector = vector or @vector or new Vector3
                m1.lookAt @position, @vector, @up
                @viewMatrix.copy m1

# -------------------------------------------------------------------------------

    class Face extends Object3D
        constructor: (x1, y1, x2, y2, img, uvData1, uvData2) ->
            super

            texture1 = new Texture(img, uvData1)
            triangle1 = new Triangle([
                x1, y1, 0
                x2, y1, 0
                x1, y2, 0
            ], texture1)

            @add triangle1

            texture2 = new Texture(img, uvData2)
            triangle2 = new Triangle([
                x1, y2, 0
                x2, y1, 0
                x2, y2, 0
            ], texture2)

            @add triangle2

# -------------------------------------------------------------------------------

    class Triangle extends Object3D
        constructor: (vertices, @texture) ->
            super

            @vertices = []
            for v, i in vertices by 3
                vec3 = new Vector3 vertices[i + 0], vertices[i + 1], vertices[i + 2]
                @vertices.push vec3

        getVerticesByProjectionMatrix: (m) ->
            ret = []
            for v in @vertices
                wm = Matrix4.multiply m, @matrixWorld
                #tmp = v.clone().applyProjection(m)
                tmp = v.clone().applyProjection(wm)
                #@localToWorld tmp
                ret = ret.concat(tmp.toArray())

            return ret


# -------------------------------------------------------------------------------

    class Cube extends Object3D
        constructor: (w, h, p, sx, sy, sz, materials) ->
            super

            w *= 0.5
            h *= 0.5
            p *= 0.5

            for i in [0...12]
                triangle = new Triangle([
                    -w,  h, p
                     w,  h, p
                    -w, -h, p
                ], new Texture(materials[0].uv_data, [
                    0  , 0  ,
                    0.5, 0  ,
                    0  , 0.5
                ]))

                @add triangle

                #texture = new Texture(groundImage, ground_1_uv)
                #triangle = new Triangle(ground_1, texture)

# -------------------------------------------------------------------------------

    class Texture
        constructor: (@uv_data, @uv_list) ->

# -------------------------------------------------------------------------------

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

    class Color
        constructor: (@r, @g, @b, @a) ->

# -------------------------------------------------------------------------------

    class Light
        constructor: (@color) ->

# -------------------------------------------------------------------------------

    class AmbientLight extends Light
        constructor: (@color) ->
            super

# -------------------------------------------------------------------------------

    class DirectionalLight extends Light
        constructor: (@color) ->
            super

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
        constructor: (@cv, @clearColor = '#fff') ->
            @g = cv.getContext '2d'
            @w = cv.width
            @h = cv.height

        render: (scene, camera) ->
            camera.updateProjectionMatrix()
            matProj = camera.getProjectionMatrix()

            @g.beginPath()
            @g.fillStyle = @clearColor
            @g.fillRect 0, 0, @w, @h

            @transformAndDraw matProj, scene.materials

        ###*
            Transform and draw.
            @param {Matrix4} mat matrix.
            @param {Array} materials.
        ###
        transformAndDraw: (mat, materials) ->

            g = @g
            results = []
            out_list = []

            for m in materials
                out_list = []
                m.updateMatrix()
                m.updateMatrixWorld()

                if m instanceof Triangle
                    vertex_list = m.getVerticesByProjectionMatrix(mat)
                    uv_image    = m.texture.uv_data
                    uv_list     = m.texture.uv_list

                    #drawTriangle(g, uv_image, out_list, uv_list, @w, @h)
                    drawTriangle(g, uv_image, vertex_list, uv_list, @w, @h)

                else if m instanceof Face
                    for c in m.children
                        vertex_list = c.getVerticesByProjectionMatrix(mat)
                        uv_image    = c.texture.uv_data
                        uv_list     = c.texture.uv_list

                        #drawTriangle(g, uv_image, out_list, uv_list)
                        drawTriangle(g, uv_image, vertex_list, uv_list, @w, @h)

                else if m instanceof Cube
                    for c in m.children
                        out_list = []
                        vertex_list = c.vertex
                        uv_image    = c.texture.uv_data
                        uv_list     = c.texture.uv_list

                        drawTriangle(g, uv_image, out_list, uv_list)

                else if m instanceof Particle
                    vertex_list = [m.v.x, m.v.y, m.v.z]

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


    exports.Object3D = Object3D
    exports.Matrix2 = Matrix2
    exports.Matrix4 = Matrix4
    exports.Camera = Camera
    exports.Renderer = Renderer
    exports.Scene = Scene
    exports.Texture = Texture
    exports.Face = Face
    exports.Triangle = Triangle
    exports.Cube = Cube
    exports.Particle = Particle
    exports.Texture = Texture
    exports.Vector3 = Vector3
    exports.Quaternion = Quaternion
