//@ sourceMappingURL=card.map
// Generated by CoffeeScript 1.6.1

(function(win, doc, exports) {
  var $, AmbientLight, Camera, Color, Cube, DEG_TO_RAD, DirectionalLight, Face, Face2, Line, MOUSE_DOWN, MOUSE_MOVE, MOUSE_UP, Matrix4, Object3D, PI, Particle, Plate, Renderer, Scene, Texture, Triangle, Vector3, camera, cos, init, isTouch, photoImage, renderer, requestAnimFrame, rotX, rotY, scene, sin, tan, _ref;
  tan = Math.tan, cos = Math.cos, sin = Math.sin, PI = Math.PI;
  _ref = window.S3D, Face2 = _ref.Face2, Object3D = _ref.Object3D, Line = _ref.Line, Color = _ref.Color, AmbientLight = _ref.AmbientLight, DirectionalLight = _ref.DirectionalLight, Plate = _ref.Plate, Face = _ref.Face, Cube = _ref.Cube, Texture = _ref.Texture, Triangle = _ref.Triangle, Matrix4 = _ref.Matrix4, Camera = _ref.Camera, Renderer = _ref.Renderer, Scene = _ref.Scene, Vector3 = _ref.Vector3, Particle = _ref.Particle;
  $ = function(selector) {
    return doc.querySelector(selector);
  };
  requestAnimFrame = (function() {
    return win.requestAnimationFrame || win.webkitRequestAnimationFrame || win.mozRequestAnimationFrame || win.msRequestAnimationFrame || function(callback) {
      return setTimeout(callback, 16);
    };
  })();
  DEG_TO_RAD = PI / 180;
  isTouch = 'ontouchstart' in window;
  MOUSE_DOWN = isTouch ? 'touchstart' : 'mousedown';
  MOUSE_MOVE = isTouch ? 'touchmove' : 'mousemove';
  MOUSE_UP = isTouch ? 'touchend' : 'mouseup';
  photoImage = null;
  rotX = 0;
  rotY = 0;
  renderer = null;
  camera = null;
  scene = null;
  init = function() {
    var aspect, base, btnFog, btnLight, btnWire, create, ctx, cv, dragging, fog, fov, h, light, moveX, moveY, photo, prevX, prevY, startZoom, w, wire;
    cv = doc.getElementById('canvas');
    ctx = cv.getContext('2d');
    w = cv.width = win.innerWidth;
    h = cv.height = win.innerHeight;
    fov = 60;
    aspect = w / h;
    photo = new Image();
    photo.onload = function() {
      photoImage = photo;
      return create();
    };
    photo.src = 'img/photo.jpg';
    camera = new Camera(40, aspect, 0.1, 10000);
    camera.position.x = 0;
    camera.position.y = 120;
    camera.position.z = 320;
    camera.lookAt(new Vector3(0, 50, 0));
    camera.lookAtLock = true;
    scene = new Scene;
    renderer = new Renderer(cv, '#111');
    win.camera = camera;
    create = function() {
      var ambLight, angle, container, dirLight, i, line, line1, line2, line3, plate1, size, x, z, _i, _j, _loop, _ref1, _ref2;
      plate1 = new Plate(500, 339, 2, 2, photoImage, photoImage);
      plate1.rotation.z = 45;
      plate1.position.set(0, 40, 0);
      plate1.scale.set(0.1, 0.1, 0.1);
      size = 200;
      line1 = new Line(0, 0, -size / 2, 0, 0, size / 2, new Color(255, 0, 0, 0.3));
      line2 = new Line(-size / 2, 0, 0, size / 2, 0, 0, new Color(0, 255, 0, 0.3));
      line3 = new Line(0, size / 2, 0, 0, -size / 2, 0, new Color(0, 0, 255, 0.3));
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
      dirLight = new DirectionalLight(0.8, (new Vector3(1, 0, 1)).normalize());
      scene.add(ambLight);
      scene.add(dirLight);
      scene.add(plate1);
      scene.add(container);
      scene.add(line1);
      scene.add(line2);
      scene.add(line3);
      angle = 0;
      return (_loop = function() {
        angle = (angle += 2) % 360;
        plate1.rotation.y = angle;
        renderer.render(scene, camera);
        return requestAnimFrame(_loop);
      })();
    };
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
    doc.addEventListener(MOUSE_UP, function(e) {
      return dragging = false;
    }, false);
    btnFog = $('#fog');
    btnLight = $('#light');
    btnWire = $('#wire');
    fog = true;
    light = true;
    wire = false;
    btnFog.addEventListener(MOUSE_DOWN, function() {
      var type;
      fog = !fog;
      type = fog ? 'ON' : 'OFF';
      btnFog.value = "フォグ[" + type + "]";
      return renderer.fog = fog;
    }, false);
    btnLight.addEventListener(MOUSE_DOWN, function() {
      var type;
      light = !light;
      type = light ? 'ON' : 'OFF';
      btnLight.value = "ライティング[" + type + "]";
      return renderer.lighting = light;
    }, false);
    return btnWire.addEventListener(MOUSE_DOWN, function() {
      var type;
      wire = !wire;
      type = wire ? 'ON' : 'OFF';
      btnWire.value = "ワイヤーフレーム[" + type + "]";
      return renderer.wireframe = wire;
    }, false);
  };
  return doc.addEventListener('DOMContentLoaded', init, false);
})(window, window.document, window);
