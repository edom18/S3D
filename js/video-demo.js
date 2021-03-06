//@ sourceMappingURL=video-demo.map
// Generated by CoffeeScript 1.6.1

(function(win, doc, exports) {
  var AmbientLight, Camera, Color, Cube, DirectionalLight, Face, Line, MOUSE_DOWN, MOUSE_MOVE, MOUSE_UP, Matrix4, Object3D, PI, Particle, Plate, Renderer, Scene, Texture, Triangle, Vector3, cos, init, isTouch, random, requestAnimFrame, sin, tan, _ref;
  random = Math.random, tan = Math.tan, cos = Math.cos, sin = Math.sin, PI = Math.PI;
  _ref = window.S3D, Object3D = _ref.Object3D, Line = _ref.Line, Color = _ref.Color, AmbientLight = _ref.AmbientLight, DirectionalLight = _ref.DirectionalLight, Plate = _ref.Plate, Face = _ref.Face, Cube = _ref.Cube, Texture = _ref.Texture, Triangle = _ref.Triangle, Matrix4 = _ref.Matrix4, Camera = _ref.Camera, Renderer = _ref.Renderer, Scene = _ref.Scene, Vector3 = _ref.Vector3, Particle = _ref.Particle;
  requestAnimFrame = (function() {
    return requestAnimationFrame || webkitRequestAnimationFrame || mozRequestAnimationFrame || msRequestAnimationFrame || function(callback) {
      return setTimeout(callback, 16);
    };
  })();
  isTouch = 'ontouchstart' in window;
  MOUSE_DOWN = isTouch ? 'touchstart' : 'mousedown';
  MOUSE_MOVE = isTouch ? 'touchmove' : 'mousemove';
  MOUSE_UP = isTouch ? 'touchend' : 'mouseup';
  init = function() {
    var aspect, base, camera, create, ctx, cv, dragging, h, initialized, moveX, moveY, prevX, prevY, renderer, scene, startZoom, video, w;
    cv = doc.getElementById('canvas');
    ctx = cv.getContext('2d');
    w = cv.width = win.innerWidth;
    h = cv.height = win.innerHeight;
    aspect = w / h;
    camera = new Camera(60, aspect, 0.1, 10000);
    camera.position.x = 200;
    camera.position.y = 120;
    camera.position.z = 280;
    camera.lookAt(new Vector3(0, 100, 0));
    camera.lookAtLock = true;
    scene = new Scene;
    renderer = new Renderer(cv, '#111');
    initialized = false;
    create = function() {
      var DEG_TO_RAD, ambLight, angle, container, dirLight, div, divH, divW, face, facies, i, j, line, line1, line2, line3, size, uv_x1, uv_x2, uv_x3, uv_x4, uv_y1, uv_y2, uv_y3, uv_y4, videoContainer, videoHeight, videoWidth, x, z, _i, _j, _k, _l, _loop, _ref1, _ref2;
      if (initialized) {
        return;
      }
      initialized = true;
      line1 = new Line(0, 0, -200, 0, 0, 200, new Color(255, 0, 0, 0.3));
      line2 = new Line(-200, 0, 0, 200, 0, 0, new Color(0, 255, 0, 0.3));
      line3 = new Line(0, 200, 0, 0, -200, 0, new Color(0, 0, 255, 0.3));
      size = 300;
      container = new Object3D;
      container.position.x = -(size * 0.5);
      container.position.z = -(size * 0.5);
      for (i = _i = 0, _ref1 = size / 10; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
        z = i * 10;
        line = new Line(0, 0, z, size, 0, z, new Color(255, 255, 255, 0.3));
        container.add(line);
      }
      for (i = _j = 0, _ref2 = size / 10; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
        x = i * 10;
        line = new Line(x, 0, 0, x, 0, size, new Color(255, 255, 255, 0.3));
        container.add(line);
      }
      ambLight = new AmbientLight(0.1);
      dirLight = new DirectionalLight(0.8, (new Vector3(-1, 1, 1)).normalize());
      videoContainer = new Object3D;
      div = 5;
      videoWidth = video.videoWidth;
      videoHeight = video.videoHeight;
      divW = videoWidth / div;
      divH = videoHeight / div;
      videoContainer.position.x = -videoWidth / (2 / 0.7);
      videoContainer.position.y = videoHeight * 0.7;
      videoContainer.scale.set(0.7, 0.7, 0.7);
      facies = [];
      for (i = _k = 0; 0 <= div ? _k < div : _k > div; i = 0 <= div ? ++_k : --_k) {
        for (j = _l = 0; 0 <= div ? _l < div : _l > div; j = 0 <= div ? ++_l : --_l) {
          uv_x1 = ((j + 0) * divW) / videoWidth;
          uv_y1 = ((i + 0) * divH) / videoHeight;
          uv_x2 = ((j + 0) * divW) / videoWidth;
          uv_y2 = ((i + 1) * divH) / videoHeight;
          uv_x3 = ((j + 1) * divW) / videoWidth;
          uv_y3 = ((i + 1) * divH) / videoHeight;
          uv_x4 = ((j + 1) * divW) / videoWidth;
          uv_y4 = ((i + 0) * divH) / videoHeight;
          face = new Face(0, 0, divW, -divH, new Texture(video, [uv_x1, uv_y1, uv_x2, uv_y2, uv_x4, uv_y4]), new Texture(video, [uv_x2, uv_y2, uv_x3, uv_y3, uv_x4, uv_y4]));
          face.position.set(j * divW, -(i * divH), ~~(random() * -500));
          face.position.originalZ = face.position.z;
          facies.push(face);
          videoContainer.add(face);
        }
      }
      scene.add(ambLight);
      scene.add(dirLight);
      scene.add(videoContainer);
      scene.add(container);
      DEG_TO_RAD = PI / 180;
      angle = 0;
      return (_loop = function() {
        var f, _len, _m;
        angle = ++angle % 360;
        for (_m = 0, _len = facies.length; _m < _len; _m++) {
          f = facies[_m];
          f.position.z = f.position.originalZ + (sin(angle * DEG_TO_RAD) * f.position.originalZ);
        }
        renderer.render(scene, camera);
        return requestAnimFrame(_loop);
      })();
    };
    video = doc.getElementById('video');
    video.autoplay = true;
    video.loop = true;
    video.addEventListener('canplaythrough', create, false);
    video.addEventListener('canplay', create, false);
    video.addEventListener('loadeddata', create, false);
    dragging = false;
    prevX = 0;
    prevY = 0;
    win.addEventListener('mousewheel', function(e) {
      camera.position.z += e.wheelDelta / 100;
      renderer.render(scene, camera);
      return e.preventDefault();
    }, false);
    base = 100;
    startZoom = 0;
    document.addEventListener('gesturechange', function(e) {
      var num;
      num = e.scale * base - base;
      camera.position.z = startZoom - num;
      renderer.render(scene, camera);
      return e.preventDefault();
    }, false);
    document.addEventListener('gesturestart', function() {
      return startZoom = camera.position.z;
    }, false);
    doc.addEventListener('touchstart', function(e) {
      return e.preventDefault();
    }, false);
    doc.addEventListener(MOUSE_DOWN, function(e) {
      dragging = true;
      prevX = isTouch ? e.touches[0].pageX : e.pageX;
      return prevY = isTouch ? e.touches[0].pageY : e.pageY;
    }, false);
    moveX = camera.position.x;
    moveY = camera.position.y;
    doc.addEventListener(MOUSE_MOVE, function(e) {
      var pageX, pageY;
      if (dragging === false) {
        return;
      }
      pageX = isTouch ? e.touches[0].pageX : e.pageX;
      pageY = isTouch ? e.touches[0].pageY : e.pageY;
      moveX -= prevX - pageX;
      moveY += prevY - pageY;
      camera.position.y = moveY;
      camera.position.x = moveX;
      prevX = pageX;
      prevY = pageY;
      return renderer.render(scene, camera);
    }, false);
    return doc.addEventListener(MOUSE_UP, function(e) {
      return dragging = false;
    }, false);
  };
  return doc.addEventListener('DOMContentLoaded', init, false);
})(window, window.document, window);
