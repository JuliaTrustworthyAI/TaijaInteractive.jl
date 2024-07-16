// onload.test.js
const {
    deleteBoard, addBoard, searchBoard, sortBoards,
    initializeCarousel, initializeDragCarousel,
    initializeSearch, initializeButtons
} = require('./onload');

// Mock global objects and methods
// Mock global functions and objects
global.fetch = jest.fn();
global.window = { location: { reload: jest.fn() } };
global.console = { log: jest.fn() };

// Helper function to mock the document.getElementById
global.document = {
    getElementById: jest.fn(),
    querySelectorAll: jest.fn(),
    getElementsByClassName: jest.fn()
};
Object.defineProperty(global, 'window', {
    value: {
        location: {
            reload: jest.fn()
        }
    },
    writable: true
});

describe("sortBoards", () => {
    let sortbar;
    let parent;
    let items;

    beforeEach(() => {
        document.body.innerHTML = `
            <select id="sortbar">
                <option value="name">Name</option>
                <option value="date">Date</option>
                <option value="unknown">Unknown</option>
            </select>
            <div id="parent">
                <div class="item" data-id="1;Charlie;2023-06-01"></div>
                <div class="item" data-id="2;Alice;2023-05-01"></div>
                <div class="item" data-id="3;Bob;2023-04-01"></div>
            </div>
        `;

        sortbar = document.getElementById("sortbar");
        parent = document.getElementById("parent");
        items = Array.from(document.getElementsByClassName("item"));
    });

    test("sorts items by name", () => {
        sortbar.value = "name";
        sortBoards();

        const sortedItems = Array.from(parent.children);
        expect(sortedItems[0].getAttribute("data-id")).toBe("2;Alice;2023-05-01");
        expect(sortedItems[1].getAttribute("data-id")).toBe("3;Bob;2023-04-01");
        expect(sortedItems[2].getAttribute("data-id")).toBe("1;Charlie;2023-06-01");
    });

    test("sorts items by date", () => {
        sortbar.value = "date";
        sortBoards();

        const sortedItems = Array.from(parent.children);
        expect(sortedItems[0].getAttribute("data-id")).toBe("3;Bob;2023-04-01");
        expect(sortedItems[1].getAttribute("data-id")).toBe("2;Alice;2023-05-01");
        expect(sortedItems[2].getAttribute("data-id")).toBe("1;Charlie;2023-06-01");
    });

    test("handles unknown sorting type", () => {
        sortbar.value = "unknown";
        console.log = jest.fn();

        sortBoards();
        expect(console.log).toHaveBeenCalledWith("unknown sorting type: unknown");
    });
});

describe("searchBoard", () => {
    let searchbar;
    let items;

    beforeEach(() => {
        document.body.innerHTML = `
            <input id="searchbar" type="text" />
            <div class="item">Board Alpha</div>
            <div class="item">Board Beta</div>
            <div class="item">Gamma Board</div>
        `;

        searchbar = document.getElementById("searchbar");
        items = Array.from(document.getElementsByClassName("item"));
    });

    test("displays all matching items when searching for 'board'", () => {
        searchbar.value = "board";
        searchBoard();

        expect(items[0].style.display).toBe("flex");
        expect(items[1].style.display).toBe("flex");
        expect(items[2].style.display).toBe("flex");
    });

    test("displays only matching items when searching for 'gamma'", () => {
        searchbar.value = "gamma";
        searchBoard();

        expect(items[0].style.display).toBe("none");
        expect(items[1].style.display).toBe("none");
        expect(items[2].style.display).toBe("flex");
    });

    test("displays all items when search input is empty", () => {
        searchbar.value = "";
        searchBoard();

        items.forEach(item => {
            expect(item.style.display).toBe("flex");
        });
    });

    test("displays no items when search input does not match any item", () => {
        searchbar.value = "zeta";
        searchBoard();

        items.forEach(item => {
            expect(item.style.display).toBe("none");
        });
    });
});

describe("addBoard", () => {
    beforeEach(() => {
        global.fetch = jest.fn();
        global.alert = jest.fn();
        jest.spyOn(window.location, 'reload').mockImplementation(() => {});
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    test("reloads the page on a successful response", async () => {
        global.fetch.mockResolvedValueOnce({
            ok: true
        });

        addBoard();
        await new Promise(resolve => setTimeout(resolve, 0));

        expect(window.location.reload).toHaveBeenCalled();
    });

    test("alerts an error message on a failed response", async () => {
        const errorMessage = "Some error";
        global.fetch.mockResolvedValueOnce({
            ok: false,
            text: jest.fn().mockResolvedValueOnce(errorMessage)
        });

        addBoard();
        await new Promise(resolve => setTimeout(resolve, 0));

        expect(global.alert).toHaveBeenCalledWith(false);
        expect(global.alert).toHaveBeenCalledWith(`An error occurred: ${errorMessage}`);
    });
});

describe("deleteBoard", () => {
    beforeEach(() => {
        global.fetch = jest.fn();
        global.alert = jest.fn();
        jest.spyOn(window.location, 'reload').mockImplementation(() => {});
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    test("reloads the page on a successful response", async () => {
        global.fetch.mockResolvedValueOnce({
            ok: true
        });

        deleteBoard(1);
        await new Promise(resolve => setTimeout(resolve, 0));

        expect(window.location.reload).toHaveBeenCalled();
    });

    test("alerts an error message on a failed response", async () => {
        const errorMessage = "Some error";
        global.fetch.mockResolvedValueOnce({
            ok: false,
            text: jest.fn().mockResolvedValueOnce(errorMessage)
        });

        deleteBoard(1);
        await new Promise(resolve => setTimeout(resolve, 0));

        expect(global.alert).toHaveBeenCalledWith(`An error occurred: ${errorMessage}`);
    });
});

describe("Carousel functionality", () => {
    beforeEach(() => {
        document.body.innerHTML = `
            <div class="container" id="carousel-container">
                <div class="carousel-view">
                    <i id="left"></i>
                    <div id="item-list" class="item-list">
                        <div class="item">
                            <div class="dashboard-buttons">
                                <button class="delete-button" data-id="1" onclick="deleteBoard(1)">X</button>
                                <button class="edit-button" data-id="1">Edit</button>
                            </div>
                            <a class="board-link" href="/pool/1">
                                <div class="dashboard-title">t1 1</div>
                            </a>
                        </div>
                        <div class="item">
                            <div class="dashboard-buttons">
                                <button class="delete-button" data-id="2" onclick="deleteBoard(2)">X</button>
                                <button class="edit-button" data-id="2">Edit</button>
                            </div>
                            <a class="board-link" href="/pool/2">
                                <div class="dashboard-title">t2 2</div>
                            </a>
                        </div>
                    </div>
                    <i id="right"></i>
                </div>
            </div>
            <input type="text" id="searchbar">
            <button id="button-create-dashboard">Create Dashboard</button>
        `;

        // Mock global functions
        global.searchBoard = jest.fn();
        global.addBoard = jest.fn();
        global.deleteBoard = jest.fn();

        // Manually trigger DOMContentLoaded event to ensure event listeners are attached
        const event = new Event('DOMContentLoaded');
        document.dispatchEvent(event);
    });

    test('prev button click should scroll left', () => {
        const list = document.getElementById('item-list');
        const prev = document.getElementById('left');
        const itemWidth = 150;
        const padding = 10;
        list.scrollLeft = 160; // Adjusted initial scroll position for clarity

        prev.click();
        expect(list.scrollLeft).toBe(0);
    });

    test('next button click should scroll right', () => {
        const list = document.getElementById('item-list');
        const next = document.getElementById('right');
        const itemWidth = 150;
        const padding = 10;

        list.scrollLeft = 0;
        next.click();
        expect(list.scrollLeft).toBe(itemWidth + padding);  // 150 + 10 padding
    });
});

describe('Board Manipulations', () => {
    beforeEach(() => {
        //fetch.resetMocks();
        document.body.innerHTML = `
            <div id="item-list" class="item-list">
                <div class="item" data-id="1;board1;2024-06-16">Board 1</div>
                <div class="item" data-id="2;board2;2024-06-15">Board 2</div>
            </div>
            <div id="left"></div>
            <div id="right"></div>
            <div id="carousel-container"></div>
            <input id="searchbar" type="text">
            <input id="sortbar" type="text">
            <button id="button-create-dashboard"></button>
            <button class="delete" data-id="1"></button>
        `;
    });

    test('should initialize carousel buttons', () => {
        initializeCarousel(150, 10);
        const list = document.getElementById('item-list');
        document.getElementById('left').click();
        expect(list.scrollLeft).toBe(-160);
        document.getElementById('right').click();
        expect(list.scrollLeft).toBe(0);
    });

    test('should initialize drag carousel', () => {
        initializeDragCarousel(150);
        const carousel = document.getElementById('item-list');
        carousel.scrollLeft = 100;
        const event = new MouseEvent('mousedown', { pageX: 0 });
        carousel.dispatchEvent(event);
        expect(carousel.scrollLeft).toBe(100);
    });

    test('should initialize search', () => {
        initializeSearch();
        document.getElementById('searchbar').value = 'board1';
        const event = new KeyboardEvent('keyup');
        document.getElementById('searchbar').dispatchEvent(event);
        const items = document.getElementsByClassName('item');
    });
});