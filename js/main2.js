//@ sourceMappingURL=main2.map
// Generated by CoffeeScript 1.6.1

(function(win, doc, exports) {
  var $, AmbientLight, Camera, Color, Cube, DEG_TO_RAD, DirectionalLight, Face, Line, MOUSE_DOWN, MOUSE_MOVE, MOUSE_UP, Matrix4, Object3D, PI, Particle, Plate, Renderer, Scene, Texture, Triangle, Vector3, camera, cos, getVideo, init, isTouch, logoImage, photoImage, renderer, requestAnimFrame, rotX, rotY, scene, sin, tan, textureImage, _ref;
  tan = Math.tan, cos = Math.cos, sin = Math.sin, PI = Math.PI;
  _ref = window.S3D, Object3D = _ref.Object3D, Line = _ref.Line, Color = _ref.Color, AmbientLight = _ref.AmbientLight, DirectionalLight = _ref.DirectionalLight, Plate = _ref.Plate, Face = _ref.Face, Cube = _ref.Cube, Texture = _ref.Texture, Triangle = _ref.Triangle, Matrix4 = _ref.Matrix4, Camera = _ref.Camera, Renderer = _ref.Renderer, Scene = _ref.Scene, Vector3 = _ref.Vector3, Particle = _ref.Particle;
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
  textureImage = null;
  logoImage = null;
  photoImage = null;
  rotX = 0;
  rotY = 0;
  renderer = null;
  camera = null;
  scene = null;
  getVideo = function() {
    var video;
    video = doc.getElementById('video');
    video.autoplay = true;
    video.loop = true;
    return video;
  };
  init = function() {
    var aspect, base, btnFog, btnLight, btnWire, cnt, create, ctx, cv, dragging, fog, fov, h, img, light, logo, moveX, moveY, photo, prevX, prevY, startZoom, video, w, wire;
    video = getVideo();
    cv = doc.getElementById('canvas');
    ctx = cv.getContext('2d');
    w = cv.width = win.innerWidth;
    h = cv.height = win.innerHeight;
    fov = 60;
    aspect = w / h;
    cnt = 3;
    img = new Image();
    logo = new Image();
    photo = new Image();
    img.onload = function() {
      textureImage = img;
      return --cnt || create();
    };
    logo.onload = function() {
      logoImage = logo;
      return --cnt || create();
    };
    photo.onload = function() {
      photoImage = photo;
      return --cnt || create();
    };
    img.src = 'img/aXjiA.png';
    logo.src = 'img/HTML5_Logo_512.png';
    photo.src = 'img/photo.jpg';
    camera = new Camera(40, aspect, 0.1, 10000);
    camera.position.x = 10;
    camera.position.y = 20;
    camera.position.z = 200;
    camera.lookAt(new Vector3(0, 50, 0));
    camera.lookAtLock = true;
    scene = new Scene;
    renderer = new Renderer(cv, '#111');
    win.camera = camera;
    create = function() {
      var ambLight, angle, container, cube1, cube2, cube3, dirLight, i, line, line1, line2, line3, materials1, materials2, materials3, particle1, particle2, particle3, particle4, particle5, plate1, plate2, size, x, z, _i, _j, _loop, _ref1, _ref2;
      materials1 = [new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0]), new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0]), new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0]), new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0]), new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0]), new Texture(photoImage, [0, 0, 0, 1, 1, 0]), new Texture(photoImage, [0, 1, 1, 1, 1, 0])];
      materials2 = [new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]), new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]), new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]), new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]), new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]), new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0])];
      materials3 = [new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1), new Color(200, 0, 0, 1)];
      cube1 = new Cube(50, 20, 20, 1, 1, 1, materials2);
      cube1.position.z = -50;
      cube1.position.y = 50;
      cube1.rotation.z = 30;
      cube1.scale.set(0.5, 0.5, 0.5);
      cube2 = new Cube(20, 20, 20, 1, 1, 1, materials1);
      cube2.position.z = -150;
      cube2.position.y = 50;
      cube2.position.x = 50;
      cube3 = new Cube(20, 20, 20, 1, 1, 1, materials3);
      cube3.position.z = -350;
      cube3.position.x = 50;
      cube3.position.y = 80;
      plate1 = new Plate(50, 50, new Texture(textureImage, [0.0, 0.5, 0.0, 1.0, 0.5, 0.5]), new Texture(textureImage, [0.0, 1.0, 0.5, 1.0, 0.5, 0.5]));
      plate1.position.x = -50;
      plate1.position.y = 10;
      plate1.position.z = -300;
      plate2 = new Plate(50, 50, new Texture(video, [0, 0, 0, 1, 1, 0]), new Texture(video, [0, 1, 1, 1, 1, 0]));
      plate2.position.y = 100;
      plate2.position.z = -500;
      line1 = new Line(0, 0, -200, 0, 0, 200, new Color(255, 0, 0, 0.3));
      line2 = new Line(-200, 0, 0, 200, 0, 0, new Color(0, 255, 0, 0.3));
      line3 = new Line(0, 200, 0, 0, -200, 0, new Color(0, 0, 255, 0.3));
      particle1 = new Particle(new Vector3(50, 50, 30), 2000);
      particle2 = new Particle(new Vector3(150, 50, 0), 3000);
      particle3 = new Particle(new Vector3(250, 30, -150), 2500);
      particle4 = new Particle(new Vector3(-150, 150, -250), 4000);
      particle5 = new Particle(new Vector3(-250, 250, 50), 3500);
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
      dirLight = new DirectionalLight(0.8, (new Vector3(0, 0, -1)).normalize());
      scene.add(ambLight);
      scene.add(dirLight);
      scene.add(particle1);
      scene.add(particle2);
      scene.add(particle3);
      scene.add(particle4);
      scene.add(particle5);
      scene.add(plate1);
      scene.add(plate2);
      scene.add(container);
      scene.add(cube1);
      scene.add(cube2);
      scene.add(cube3);
      scene.add(line1);
      scene.add(line2);
      scene.add(line3);
      angle = 0;
      return (_loop = function() {
        var s;
        angle = ++angle % 360;
        plate1.rotation.z = angle;
        plate2.rotation.x = angle * 3;
        cube1.rotation.z = angle;
        cube2.rotation.x = angle * 2;
        cube3.rotation.x = angle * 3;
        cube3.rotation.y = angle * 3;
        cube3.rotation.z = angle * 3;
        s = 1 + sin(angle * DEG_TO_RAD);
        cube3.scale.set(s, s, s);
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
