//@ sourceMappingURL=main2.map
// Generated by CoffeeScript 1.6.1

(function(win, doc, exports) {
  var Camera, DEG_TO_RAD, MOUSE_DOWN, MOUSE_MOVE, MOUSE_UP, Matrix4, Mesh, PI, Particle, Renderer, Scene, Texture, Vector3, camera, cos, dragging, groundImage, ground_1, ground_1_uv, ground_2, ground_2_uv, init, isTouch, renderer, roof_1, roof_1_uv, roof_2, roof_2_uv, rotX, rotY, rotZ, scene, sin, start, tan, textureImage, wall_1, wall_1_uv, wall_2, wall_2_uv, wall_3, wall_3_uv, wall_4, wall_4_uv, wall_5, wall_5_uv, wall_6, wall_6_uv, wall_7, wall_7_uv, wall_8, wall_8_uv, _ref;
  tan = Math.tan, cos = Math.cos, sin = Math.sin, PI = Math.PI;
  _ref = window.S3D, Texture = _ref.Texture, Mesh = _ref.Mesh, Matrix4 = _ref.Matrix4, Camera = _ref.Camera, Renderer = _ref.Renderer, Scene = _ref.Scene, Vector3 = _ref.Vector3, Particle = _ref.Particle;
  DEG_TO_RAD = PI / 180;
  isTouch = 'ontouchstart' in window;
  MOUSE_DOWN = isTouch ? 'touchstart' : 'mousedown';
  MOUSE_MOVE = isTouch ? 'touchmove' : 'mousemove';
  MOUSE_UP = isTouch ? 'touchend' : 'mouseup';
  roof_1 = [-4, 4, 4, 4, 4, 4, -4, 4, -4];
  roof_2 = [-4, 4, -4, 4, 4, 4, 4, 4, -4];
  ground_1 = [-10, -4, 10, 10, -4, 10, -10, -4, -10];
  ground_2 = [-10, -4, -10, 10, -4, 10, 10, -4, -10];
  wall_1 = [-4, 4, -4, 4, 4, -4, -4, -4, -4];
  wall_2 = [-4, -4, -4, 4, 4, -4, 4, -4, -4];
  wall_3 = [-4, 4, 4, -4, 4, -4, -4, -4, 4];
  wall_4 = [-4, -4, 4, -4, 4, -4, -4, -4, -4];
  wall_5 = [4, 4, -4, 4, 4, 4, 4, -4, -4];
  wall_6 = [4, -4, -4, 4, 4, 4, 4, -4, 4];
  wall_7 = [4, 4, 4, -4, 4, 4, 4, -4, 4];
  wall_8 = [4, -4, 4, -4, 4, 4, -4, -4, 4];
  ground_1_uv = [0, 0, 0.5, 0, 0, 0.5];
  ground_2_uv = [0, 0.5, 0.5, 0, 0.5, 0.5];
  roof_1_uv = [0, 0, 0.5, 0, 0, 0.5];
  roof_2_uv = [0, 0.5, 0.5, 0, 0.5, 0.5];
  wall_1_uv = [0, 0.5, 0.5, 0.5, 0, 1];
  wall_2_uv = [0, 1, 0.5, 0.5, 0.5, 1];
  wall_3_uv = [0.5, 0, 1, 0, 0.5, 0.5];
  wall_4_uv = [0.5, 0.5, 1, 0, 1, 0.5];
  wall_5_uv = [0.5, 0, 1, 0, 0.5, 0.5];
  wall_6_uv = [0.5, 0.5, 1, 0, 1, 0.5];
  wall_7_uv = [0, 0.5, 0.5, 0.5, 0, 1];
  wall_8_uv = [0, 1, 0.5, 0.5, 0.5, 1];
  textureImage = null;
  groundImage = null;
  rotX = 0;
  rotY = 0;
  rotZ = 0;
  renderer = null;
  camera = null;
  scene = null;
  start = function() {
    var img, img2;
    img = new Image();
    img2 = new Image();
    img.onload = function() {
      textureImage = img;
      return renderer.render(scene, camera);
    };
    img2.onload = function() {
      groundImage = img2;
      return renderer.render(scene, camera);
    };
    img.src = 'http://jsrun.it/assets/a/X/j/i/aXjiA.png';
    return img2.src = 'http://jsrun.it/assets/8/u/u/1/8uu1X.png';
  };
  init = function() {
    var aspect, cnt, create, ctx, cv, fov, h, img, img2, w;
    cv = doc.getElementById('canvas');
    ctx = cv.getContext('2d');
    w = cv.width = win.innerWidth;
    h = cv.height = win.innerHeight;
    fov = 60;
    aspect = w / h;
    cnt = 2;
    img = new Image();
    img2 = new Image();
    img.onload = function() {
      textureImage = img;
      return --cnt || create();
    };
    img2.onload = function() {
      groundImage = img2;
      return --cnt || create();
    };
    img.src = 'http://jsrun.it/assets/a/X/j/i/aXjiA.png';
    img2.src = 'http://jsrun.it/assets/8/u/u/1/8uu1X.png';
    camera = new Camera(90, aspect, 1, 2000);
    camera.position.z = 2;
    scene = new Scene;
    renderer = new Renderer(cv);
    return create = function() {
      var mesh, texture;
      texture = new Texture(groundImage, ground_1_uv);
      mesh = new Mesh(ground_1, texture);
      scene.add(mesh);
      texture = new Texture(groundImage, ground_2_uv);
      mesh = new Mesh(ground_2, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, roof_1_uv);
      mesh = new Mesh(roof_1, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, roof_2_uv);
      mesh = new Mesh(roof_2, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_1_uv);
      mesh = new Mesh(wall_1, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_2_uv);
      mesh = new Mesh(wall_2, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_3_uv);
      mesh = new Mesh(wall_3, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_4_uv);
      mesh = new Mesh(wall_4, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_5_uv);
      mesh = new Mesh(wall_5, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_6_uv);
      mesh = new Mesh(wall_6, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_7_uv);
      mesh = new Mesh(wall_7, texture);
      scene.add(mesh);
      texture = new Texture(textureImage, wall_8_uv);
      mesh = new Mesh(wall_8, texture);
      scene.add(mesh);
      return renderer.render(scene, camera);
    };
  };
  dragging = false;
  win.addEventListener('mousewheel', function(e) {
    var fov;
    fov = fov - (e.wheelDelta / 100);
    if (fov < 10) {
      fov = 10;
    }
    if (fov > 170) {
      fov = 170;
    }
    renderer.render(scene, camera);
    return e.preventDefault();
  }, false);
  doc.addEventListener('touchstart', function(e) {
    return e.preventDefault();
  }, false);
  doc.addEventListener(MOUSE_DOWN, function(e) {
    var prevX, prevY;
    dragging = true;
    prevX = isTouch ? e.touches[0].pageX : e.pageX;
    return prevY = isTouch ? e.touches[0].pageY : e.pageY;
  }, false);
  doc.addEventListener(MOUSE_MOVE, function(e) {
    var pageX, pageY, prevX, prevY;
    if (dragging === false) {
      return;
    }
    pageX = isTouch ? e.touches[0].pageX : e.pageX;
    pageY = isTouch ? e.touches[0].pageY : e.pageY;
    rotY += (prevX - pageX) / 100;
    rotX += (prevY - pageY) / 100;
    prevX = pageX;
    prevY = pageY;
    return renderer.render(scene, camera);
  }, false);
  doc.addEventListener(MOUSE_UP, function(e) {
    return dragging = false;
  }, false);
  return doc.addEventListener('DOMContentLoaded', init, false);
})(window, window.document, window);
