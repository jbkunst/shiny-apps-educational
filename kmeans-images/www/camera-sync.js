window.kmeansSyncPlotlyCamera = function(el, x, options) {
  function getPlotlyElement(node) {
    if (!node) return null;

    return node.classList.contains("js-plotly-plot")
      ? node
      : node.querySelector(".js-plotly-plot");
  }

  function cloneCamera(camera) {
    return JSON.parse(JSON.stringify(camera));
  }

  const source = getPlotlyElement(el);

  if (!source) return;

  const group = options.group || "default";
  const bindingKey = "__camera_sync_" + group + "_" + options.target;

  window.__plotlyCameraSync = window.__plotlyCameraSync || {};

  if (source[bindingKey]) return;

  source[bindingKey] = true;

  function getDirection() {
    const checked = document.querySelector(
      'input[name="sync_direction"]:checked'
    );

    return checked ? checked.value : "both";
  }

  function directionEnabled() {
    const direction = getDirection();

    return (
      direction === "both" ||
      direction === options.direction
    );
  }

  function getTarget() {
    const container = document.getElementById(options.target);

    return getPlotlyElement(container);
  }

  function currentCamera(plot) {
    if (
      plot &&
      plot._fullLayout &&
      plot._fullLayout.scene &&
      plot._fullLayout.scene.camera
    ) {
      return cloneCamera(plot._fullLayout.scene.camera);
    }

    return null;
  }

  function eventCamera(eventData) {
    if (eventData && eventData["scene.camera"]) {
      return cloneCamera(eventData["scene.camera"]);
    }

    return currentCamera(source);
  }

  function applyCamera(plot, camera) {
    if (!plot || !camera || !window.Plotly) return;

    plot.__cameraSyncDepth = (plot.__cameraSyncDepth || 0) + 1;

    Promise.resolve(
      Plotly.relayout(plot, { "scene.camera": cloneCamera(camera) })
    ).finally(function() {
      plot.__cameraSyncDepth = Math.max(
        0,
        (plot.__cameraSyncDepth || 1) - 1
      );
    });
  }

  function synchronize(eventData) {
    if (!directionEnabled()) return;
    if ((source.__cameraSyncDepth || 0) > 0) return;

    const target = getTarget();
    const camera = eventCamera(eventData);

    if (!target || !camera || !window.Plotly) return;

    window.__plotlyCameraSync[group] = cloneCamera(camera);
    source.__pendingCamera = camera;

    if (source.__cameraSyncFrame) return;

    source.__cameraSyncFrame = requestAnimationFrame(function() {
      source.__cameraSyncFrame = null;

      const nextCamera = source.__pendingCamera;
      source.__pendingCamera = null;

      applyCamera(target, nextCamera);
    });
  }

  source.on("plotly_relayouting", synchronize);
  source.on("plotly_relayout", synchronize);

  if (window.Shiny && options.readyInput) {
    Shiny.setInputValue(options.readyInput, Date.now(), { priority: "event" });
  }

  requestAnimationFrame(function() {
    applyCamera(source, window.__plotlyCameraSync[group]);
  });
};
