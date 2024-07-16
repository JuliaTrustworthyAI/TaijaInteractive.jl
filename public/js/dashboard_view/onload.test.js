const { fileValidation, deleteElement, pointerDown, pointerUp, pointerMove, hydrateDraggable, hydrateDragContainer, modelFileValidation, createCounter, createDatasetInfo, createModelInfo,toggleOptions, loadProperties } = require('./onload');

describe('fileValidation', () => {
    global.document.getElementById = jest.fn();
    global.alert = jest.fn();
    let mockInput;

    beforeEach(() => {
        // Reset the mock before each test
        mockInput = { value: '' };
        document.getElementById.mockReturnValue(mockInput);
        global.alert.mockClear();
    });

    test('should return true for a valid .csv file', () => {
        mockInput.value = 'testfile.csv';
        
        const result = fileValidation();
        
        expect(result).toBe(true);
        expect(mockInput.value).toBe('testfile.csv');
        expect(alert).not.toHaveBeenCalled();
    });

    test('should alert and clear input for an invalid file type', () => {
        mockInput.value = 'testfile.txt';
        
        const result = fileValidation();
        
        expect(result).toBe(false);
        expect(mockInput.value).toBe(''); // input should be cleared
        expect(alert).toHaveBeenCalledWith('Invalid file type');
    });

    test('should alert and clear input for no file extension', () => {
        mockInput.value = 'testfile';
        
        const result = fileValidation();
        
        expect(result).toBe(false);
        expect(mockInput.value).toBe(''); // input should be cleared
        expect(alert).toHaveBeenCalledWith('Invalid file type');
    });

    test('should handle an empty input value', () => {
        mockInput.value = '';
        
        const result = fileValidation();
        
        expect(result).toBe(false);
        expect(mockInput.value).toBe(''); // input should remain empty
        expect(alert).toHaveBeenCalledWith('Invalid file type');
    });
});


describe('deleteElement', () => {
  let originalConfirm;
  let originalFetch;

  beforeEach(() => {
    // Mock confirm function
    originalConfirm = window.confirm;
    window.confirm = jest.fn();

    // Mock fetch function
    originalFetch = window.fetch;
    window.fetch = jest.fn();

    // Set up the DOM
    document.body.innerHTML = `
      <div data_id="1">Element 1</div>
      <div data_id="2">Element 2</div>
    `;
  });

  afterEach(() => {
    // Restore original functions
    window.confirm = originalConfirm;
    window.fetch = originalFetch;
  });

  test('cancel', () => {
    window.confirm.mockReturnValueOnce(false);
    
    deleteElement('1');
    
    expect(document.querySelector(`div[data_id='1']`)).not.toBeNull();
  });

  test('should delete the element if user confirms and fetch succeeds', async () => {
    window.confirm.mockReturnValueOnce(true);
    window.fetch.mockResolvedValueOnce({ ok: true });

    deleteElement('1');
    
    // Wait for promises to resolve
    await Promise.resolve();

    expect(document.querySelector(`div[data_id='1']`)).toBeNull();
  });

  test('should not delete the element if fetch fails', async () => {
    window.confirm.mockReturnValueOnce(true);
    window.fetch.mockResolvedValueOnce({ ok: false });

    deleteElement('1');
    
    // Wait for promises to resolve
    await Promise.resolve();

    expect(document.querySelector(`div[data_id='1']`)).not.toBeNull();
  });

});

describe('pointerDown', () => {
  let state, positions, event, targetElement;

  beforeEach(() => {
      // Initial state
      state = {
          dragging: false,
          pointerId: null,
          mouseOffsetX: null,
          mouseOffsetY: null,
          beingDragged: null,
          movement: null,
      };

      // Initial positions (can be adjusted based on requirements)
      positions = {};

      // Mock target element with getBoundingClientRect
      targetElement = {
          getBoundingClientRect: jest.fn(() => ({
              left: 100,
              top: 200,
          })),
          currentTarget: 'mockElement',
      };

      // Mock event object
      event = {
          clientX: 150,
          clientY: 250,
          pointerId: 1,
          target: targetElement,
          currentTarget: targetElement,
      };
  });

  test('initializes state correctly when starting a drag', () => {
      const handler = pointerDown(positions, state);
      handler(event);

      expect(state.dragging).toBe(true);
      expect(state.pointerId).toBe(event.pointerId);
      expect(state.mouseOffsetX).toBe(50); // clientX - left (150 - 100)
      expect(state.mouseOffsetY).toBe(50); // clientY - top (250 - 200)
      expect(state.beingDragged).toBe(targetElement);
      expect(state.movement).toBe(false);
  });

  test('does nothing if already dragging with a different pointer', () => {
      // Set state as if another pointer is already dragging
      state.dragging = true;
      state.pointerId = 2; // Different pointerId

      const handler = pointerDown(positions, state);
      handler(event);

      // State should remain unchanged
      expect(state.dragging).toBe(true);
      expect(state.pointerId).toBe(2);
      expect(state.mouseOffsetX).toBeNull();
      expect(state.mouseOffsetY).toBeNull();
      expect(state.beingDragged).toBeNull();
      expect(state.movement).toBeNull();
  });

  test('updates state properties correctly when dragging starts', () => {
      const handler = pointerDown(positions, state);
      handler(event);

      expect(state.dragging).toBe(true);
      expect(state.pointerId).toBe(event.pointerId);
      expect(state.mouseOffsetX).toBe(50); // clientX - left (150 - 100)
      expect(state.mouseOffsetY).toBe(50); // clientY - top (250 - 200)
      expect(state.beingDragged).toBe(targetElement);
      expect(state.movement).toBe(false);
  });
});

describe('pointerUp function', () => {
  let state, positions, event, beingDraggedElement, outerBoxElement;

  beforeEach(() => {
      // Initial state
      state = {
          dragging: false,
          pointerId: null,
          mouseOffsetX: null,
          mouseOffsetY: null,
          beingDragged: null,
          movement: null,
      };

      // Initial positions (can be adjusted based on requirements)
      positions = {};

      // Mock being dragged element with getBoundingClientRect and getAttribute
      beingDraggedElement = {
          getBoundingClientRect: jest.fn(() => ({
              left: 200,
              top: 300,
          })),
          getAttribute: jest.fn(() => '123'),
      };

      // Mock outer box element with getBoundingClientRect
      outerBoxElement = {
          getBoundingClientRect: jest.fn(() => ({
              left: 100,
              top: 200,
          })),
      };

      // Mock event object
      event = {
          pointerId: 1,
          currentTarget: outerBoxElement,
      };

      // Mock fetch
      global.fetch = jest.fn(() =>
          Promise.resolve({
              ok: true,
          })
      );
  });

  afterEach(() => {
      // Clean up mocks
      jest.clearAllMocks();
  });

  test('does nothing if not dragging or pointerId does not match', () => {
      state.dragging = false;


      const handler = pointerUp(positions, state);
      handler(event);

      expect(state.dragging).toBe(false);
      expect(state.pointerId).toBeNull();

      state.dragging = true;
      state.pointerId = 2; // Different pointerId

      handler(event);

      expect(state.dragging).toBe(true);
      expect(state.pointerId).toBe(2);
  });

  test('does nothing if movement is false', () => {
      state.dragging = true;
      state.pointerId = 1;
      state.movement = false;

      const handler = pointerUp(positions, state);
      handler(event);

      expect(state.dragging).toBe(true);
      expect(state.pointerId).toBe(1);
      expect(global.fetch).not.toHaveBeenCalled();
  });

  test('updates state and makes a network request when dragging stops', async () => {
      state.dragging = true;
      state.pointerId = 1;
      state.movement = true;
      state.beingDragged = beingDraggedElement;

      const handler = pointerUp(positions, state);
      await handler(event);

      expect(state.dragging).toBe(false);
      expect(state.pointerId).toBeNull();

      const expectedUrl = "/dashboardelements/123/position/100/100";
      expect(global.fetch).toHaveBeenCalledWith(expectedUrl, { method: "GET" });
  });

  test('shows an alert if the network request fails', async () => {
      global.fetch.mockImplementationOnce(() =>
          Promise.resolve({
              ok: false,
          })
      );
      jest.spyOn(window, 'alert').mockImplementation(() => {});

      state.dragging = true;
      state.pointerId = 1;
      state.movement = true;
      state.beingDragged = beingDraggedElement;

      const handler = pointerUp(positions, state);
      await handler(event);

      expect(state.dragging).toBe(false);
      expect(state.pointerId).toBeNull();

      const expectedUrl = "/dashboardelements/123/position/100/100";
      expect(global.fetch).toHaveBeenCalledWith(expectedUrl, { method: "GET" });
      expect(window.alert).toHaveBeenCalledWith("Drag and drop does not work");
  });
});

describe('pointerMove function', () => {
  let state, positions, event, beingDraggedElement, outerBoxElement;

  beforeEach(() => {
      // Initial state
      state = {
          dragging: false,
          pointerId: null,
          mouseOffsetX: null,
          mouseOffsetY: null,
          beingDragged: null,
          movement: null,
      };

      // Initial positions (can be adjusted based on requirements)
      positions = {};

      // Mock being dragged element with getBoundingClientRect and getAttribute
      beingDraggedElement = {
          getBoundingClientRect: jest.fn(() => ({
              left: 200,
              top: 300,
              width: 50,
              height: 50,
          })),
          getAttribute: jest.fn(() => 'mockElement'),
          style: {
              left: '0px',
              top: '0px',
          },
      };

      // Mock outer box element with getBoundingClientRect
      outerBoxElement = {
          getBoundingClientRect: jest.fn(() => ({
              left: 100,
              top: 200,
              width: 500,
              height: 500,
          })),
      };

      // Mock event object
      event = {
          pointerId: 1,
          clientX: 300,
          clientY: 400,
          currentTarget: outerBoxElement,
      };
  });

  test('does nothing if not dragging or pointerId does not match', () => {
      state.dragging = false;

      const handler = pointerMove(positions, state);
      handler(event);

      expect(state.movement).toBeNull();
      expect(beingDraggedElement.style.left).toBe('0px');
      expect(beingDraggedElement.style.top).toBe('0px');

      state.dragging = true;
      state.pointerId = 2; // Different pointerId

      handler(event);

      expect(state.movement).toBeNull();
      expect(beingDraggedElement.style.left).toBe('0px');
      expect(beingDraggedElement.style.top).toBe('0px');
  });

  test('does nothing if beingDragged is null', () => {
      state.dragging = true;
      state.pointerId = 1;
      state.beingDragged = null;

      const handler = pointerMove(positions, state);
      handler(event);

      expect(state.movement).toBeNull();
  });

  test('updates the position of the dragged element and the positions object correctly within bounds', () => {
      state.dragging = true;
      state.pointerId = 1;
      state.mouseOffsetX = 20;
      state.mouseOffsetY = 30;
      state.beingDragged = beingDraggedElement;

      const handler = pointerMove(positions, state);
      handler(event);

      expect(state.movement).toBe(true);

      const expectedLeft = '180px'; // clientX (300) - outerBox.left (100) - mouseOffsetX (20)
      const expectedTop = '170px'; // clientY (400) - outerBox.top (200) - mouseOffsetY (30)

      expect(beingDraggedElement.style.left).toBe(expectedLeft);
      expect(beingDraggedElement.style.top).toBe(expectedTop);

      expect(positions['mockElement']).toEqual([180, 170]);
  });

  test('keeps the dragged element within the bounds of the container', () => {
      state.dragging = true;
      state.pointerId = 1;
      state.mouseOffsetX = 20;
      state.mouseOffsetY = 30;
      state.beingDragged = beingDraggedElement;

      // Test for position beyond right boundary
      event.clientX = 700;
      event.clientY = 400;
      let handler = pointerMove(positions, state);
      handler(event);

      expect(beingDraggedElement.style.left).toBe('450px'); // outerBox.width (500) - bdRect.width (50)
      expect(beingDraggedElement.style.top).toBe('170px');
      expect(positions['mockElement']).toEqual([450, 170]);

      // Test for position beyond bottom boundary
      event.clientX = 300;
      event.clientY = 800;
      handler = pointerMove(positions, state);
      handler(event);

      expect(beingDraggedElement.style.left).toBe('180px');
      expect(beingDraggedElement.style.top).toBe('450px'); // outerBox.height (500) - bdRect.height (50)
      expect(positions['mockElement']).toEqual([180, 450]);

      // Test for position beyond left boundary
      event.clientX = 50;
      event.clientY = 400;
      handler = pointerMove(positions, state);
      handler(event);

      expect(beingDraggedElement.style.left).toBe('0px'); // minimum x position
      expect(beingDraggedElement.style.top).toBe('170px');
      expect(positions['mockElement']).toEqual([0, 170]);

      // Test for position beyond top boundary
      event.clientX = 300;
      event.clientY = 100;
      handler = pointerMove(positions, state);
      handler(event);

      expect(beingDraggedElement.style.left).toBe('180px');
      expect(beingDraggedElement.style.top).toBe('0px'); // minimum y position
      expect(positions['mockElement']).toEqual([180, 0]);
  });
});

describe('hydrateDraggable function', () => {
  let el, positions, state, outerBox, mockPointerDown;

  beforeEach(() => {
      // Initial positions
      positions = {};

      // Initial state
      state = {
          dragging: false,
          pointerId: null,
          mouseOffsetX: null,
          mouseOffsetY: null,
          beingDragged: null,
          movement: null,
      };

      // Mock outer box element with getBoundingClientRect
      outerBox = {
          left: 100,
          top: 200,
          getBoundingClientRect: jest.fn(() => ({
              left: 100,
              top: 200,
          })),
      };

      // Mock draggable element with getBoundingClientRect and getAttribute
      el = {
          getBoundingClientRect: jest.fn(() => ({
              left: 300,
              top: 400,
          })),
          getAttribute: jest.fn(() => 'mockElement'),
          addEventListener: jest.fn(),
      };

      // Mock pointerDown function
      mockPointerDown = jest.fn(() => jest.fn());
  });

  test('stores the initial position of the draggable element correctly', () => {
      hydrateDraggable(el, positions, state, outerBox);

      const expectedPosition = [200, 200]; // myBox.left (300) - outerBox.left (100), myBox.top (400) - outerBox.top (200)
      expect(positions['mockElement']).toEqual(expectedPosition);
  });

  test('adds the pointerdown event listener to the element', () => {
      hydrateDraggable(el, positions, state, outerBox);

      expect(el.addEventListener).toHaveBeenCalledWith('pointerdown', expect.any(Function));
  });
});

describe('hydrateDragContainer function', () => {
    let el, positions, mockHydrateDraggable, mockPointerMove, mockPointerUp;

    beforeEach(() => {
        // Initial positions
        positions = {};

        // Mock container element with querySelectorAll and addEventListener
        el = {
            querySelectorAll: jest.fn(() => []),
            getBoundingClientRect: jest.fn(() => ({
                left: 100,
                top: 200,
                width: 500,
                height: 500,
            })),
            addEventListener: jest.fn(),
        };

        // Mock hydrateDraggable, pointerMove, and pointerUp functions
        mockHydrateDraggable = jest.fn();
        mockPointerMove = jest.fn(() => jest.fn());
        mockPointerUp = jest.fn(() => jest.fn());

        global.hydrateDraggable = mockHydrateDraggable;
        global.pointerMove = mockPointerMove;
        global.pointerUp = mockPointerUp;
    });

    test('initializes positions object if null or undefined', () => {
        const result = hydrateDragContainer(el, null);

        expect(result).toEqual({});
    });

    test('adds pointermove and pointerup event listeners to the container element', () => {
        hydrateDragContainer(el, positions);

        expect(el.addEventListener).toHaveBeenCalledWith('pointermove', expect.any(Function));
        expect(el.addEventListener).toHaveBeenCalledWith('pointerup', expect.any(Function));
    });

    test('returns the updated positions object', () => {
        const result = hydrateDragContainer(el, positions);

        expect(result).toBe(positions);
    });

    test('handles the case when container element is null', () => {
        console.error = jest.fn();

        const result = hydrateDragContainer(null, positions);

        expect(console.error).toHaveBeenCalledWith("Container element not found");
        expect(result).toBeUndefined();
    });
});

describe('modelFileValidation', () => {
  let fileInput;
  let originalAlert;
  let getElementByIdMock;

  beforeAll(() => {
      originalAlert = global.alert;
      global.alert = jest.fn();
  });

  beforeEach(() => {
      fileInput = { value: '' };
      getElementByIdMock = jest.spyOn(document, 'getElementById').mockReturnValue(fileInput);
      global.alert.mockClear();
  });

  afterAll(() => {
      global.alert = originalAlert;
      getElementByIdMock.mockRestore();
  });

  test('should return false and alert "Invalid file type" for non-.bson file', () => {
      fileInput.value = 'test.txt';
      const result = modelFileValidation();
      expect(result).toBe(false);
      expect(global.alert).toHaveBeenCalledWith('Invalid file type');
      expect(fileInput.value).toBe('');
  });

  test('should return true for .bson file', () => {
      fileInput.value = 'test.bson';
      const result = modelFileValidation();
      expect(result).toBe(true);
      expect(global.alert).not.toHaveBeenCalled();
  });

  test('should return false and alert "Invalid file type" for file without extension', () => {
      fileInput.value = 'test';
      const result = modelFileValidation();
      expect(result).toBe(false);
      expect(global.alert).toHaveBeenCalledWith('Invalid file type');
      expect(fileInput.value).toBe('');
  });
});

describe('Redirection functions', () => {
    global.document.getElementById = jest.fn();
    const originalLocation = window.location;
    delete window.location; // This is necessary because window.location is read-only
    window.location = { href: '' };
    let mockElements;

    beforeEach(() => {
        // Reset the mock elements before each test
        mockElements = {
            "classifier-selector": { value: '' },
            "generator-selector": { value: '' },
            "data-selector": { value: '' },
            "data-selector-for-info": { value: '' },
            "model-selector-for-info": { value: '' },
            "factual": { value: '' },
            "target": { value: '' }
        };

        document.getElementById.mockImplementation((id) => mockElements[id]);

        window.location.href = 'http://example.com/dashboard/12345';
    });

    afterEach(() => {
        jest.clearAllMocks(); // Clear mocks after each test
    });

    test('createCounter should construct the correct URL and redirect', () => {
        mockElements["classifier-selector"].value = 'model1';
        mockElements["generator-selector"].value = 'gen1';
        mockElements["data-selector"].value = 'data1';
        mockElements["factual"].value = 'fact1';
        mockElements["target"].value = 'target1';

        createCounter();

        expect(window.location.href).toBe("/pool/generateCounterfactual/gen1/model1/data1/12345/fact1/target1");
    });

    test('createDatasetInfo should construct the correct URL and redirect', () => {
        mockElements["data-selector-for-info"].value = 'data2';

        createDatasetInfo();

        expect(window.location.href).toBe("http://example.com/dashboard/12345/createDatasetInfo/data2");
    });

    test('createModelInfo should construct the correct URL and redirect', () => {
        mockElements["model-selector-for-info"].value = 'model2';

        createModelInfo();

        expect(window.location.href).toBe("12345/createModelInfo/model2");
    });
    //window.location = originalLocation;
});

describe('UI functions', () => {
    global.document.getElementById = jest.fn();
    global.document.getElementsByClassName = jest.fn();
    global.alert = jest.fn();
    let mockOptionsElement, mockPropertiesElement, mockForms, mockFormElements;

    beforeEach(() => {
        // Mocking DOM elements
        mockOptionsElement = { style: { display: '' } };
        mockPropertiesElement = { style: { display: '' } };
        mockFormElements = [
            { style: { display: '' } },
            { style: { display: '' } },
            { style: { display: '' } }
        ];

        document.getElementById.mockImplementation((id) => {
            if (id === "options") return mockOptionsElement;
            if (id === "properties") return mockPropertiesElement;
            if (id === "model-info-form") return { style: { display: '' } };
            if (id === "counterfactual-form") return { style: { display: '' } };
            if (id === "dataset-info-form") return { style: { display: '' } };
            return null;
        });

        document.getElementsByClassName.mockImplementation((className) => {
            if (className === "element-form") return mockFormElements;
            return [];
        });

        global.alert.mockClear(); // Reset alert mock
    });

    afterEach(() => {
        jest.clearAllMocks(); // Clear all mocks after each test
    });

    test('toggleOptions should set display to flex if not already flex', () => {
        mockOptionsElement.style.display = 'none';

        toggleOptions();

        expect(mockOptionsElement.style.display).toBe('flex');
    });

    test('toggleOptions should set display to none if already flex', () => {
        mockOptionsElement.style.display = 'flex';

        toggleOptions();

        expect(mockOptionsElement.style.display).toBe('none');
    });

    test('loadProperties should display the properties container', () => {
        loadProperties('modelExplanation');

        expect(mockPropertiesElement.style.display).toBe('flex');
    });

    test('loadProperties should hide all elements with class element-form', () => {
        loadProperties('counterfactual');

        mockFormElements.forEach(form => {
            expect(form.style.display).toBe('none');
        });
    });

    test('loadProperties should display model-info-form for modelExplanation', () => {
        const mockModelInfoForm = { style: { display: '' } };
        document.getElementById.mockReturnValueOnce(mockModelInfoForm);

        loadProperties('modelExplanation');

        expect(mockModelInfoForm.style.display).toBe('flex');
    });

    test('loadProperties should display counterfactual-form for counterfactual', () => {
        const mockCounterfactualForm = { style: { display: '' } };
        document.getElementById.mockReturnValueOnce(mockCounterfactualForm);

        loadProperties('counterfactual');

        expect(mockCounterfactualForm.style.display).toBe('flex');
    });

    test('loadProperties should display dataset-info-form for dataExplanation', () => {
        const mockDatasetInfoForm = { style: { display: '' } };
        document.getElementById.mockReturnValueOnce(mockDatasetInfoForm);

        loadProperties('dataExplanation');

        expect(mockDatasetInfoForm.style.display).toBe('flex');
    });

    test('loadProperties should alert for unimplemented options', () => {
        loadProperties('fineTune');

        expect(alert).toHaveBeenCalledWith("Not yet implemented: fineTune");
    });

    test('loadProperties should alert for unknown options', () => {
        loadProperties('unknownOption');

        expect(alert).toHaveBeenCalledWith("Not yet implemented: unknownOption");
    });
});