Grid grid = null;
int width = 600;
int height = 600;
int cell_size = 5;
Cursor cursor = null;

void setup() {
    size(width, height);
    grid = new Grid(width / cell_size, height / cell_size);
    grid.setWall(grid.n_rows/4, grid.n_cols/4, grid.n_rows/4, grid.n_cols/4*3);
    grid.setWall(grid.n_rows/4, grid.n_cols/4*3+1, grid.n_rows/4*3, grid.n_cols/4*3+1);
    grid.setWall(grid.n_rows/4*3+1, grid.n_cols/4+1, grid.n_rows/4*3+1, grid.n_cols/4*3+1);
    grid.setWall(grid.n_rows/4+1, grid.n_cols/4, grid.n_rows/4*3+1, grid.n_cols/4);
    // grid.setWallState(0, 0);
    // grid.setWallState(1, 1);
    // grid.setWallState(2, 0);
    // grid.setWallState(3, 1);
    grid.setZones();
    //grid.showZones();
}

void draw() {
}

void reset() {
    cursor = null;
    grid.reset();
}

void mousePressed() {
    PVector gc = grid.getCell(mouseX, mouseY);
    if (cursor == null) {
        cursor = new Cursor(gc);
    }
    cursor.pick(gc);
}

void mouseDragged() {
    if (cursor.is_picked) {
        cursor.move(grid.getCell(mouseX, mouseY));
    }
}

void mouseReleased() {
    cursor.is_picked = false;
}

void keyPressed() {
    if (key == 'r') {
        //println("*reset*");
        reset();
    } else if (key == 'b') {
        if (cursor != null) {
            cursor.back(10);
        }
    }
}

boolean eq(PVector v1, PVector v2) {
    return (v1.x == v2.x && v1.y == v2.y && v1.z == v2.z);
}

boolean adj(PVector v1, PVector v2) {
    return abs(v1.x - v2.x) <= 1 && abs(v1.y - v2.y) <= 1;
}

class Grid {

    Cell[][] cells;
    int n_rows, n_cols;
    ArrayList<ArrayList> wall_gcs;
    ArrayList<Integer> wall_states; 

    Grid(int nr, int nc) {
        n_rows = nr;
        n_cols = nc;
        wall_gcs = new ArrayList();
        wall_states = new ArrayList();
        cells = new Cell[n_rows + 2][n_cols + 2]; // add 6-cell padding to each side
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                cells[i][j] = new Cell((j-1)*cell_size, (i-1)*cell_size);
            }
        }        
    }

    Cell get(PVector gc) {
        return cells[int(gc.x)][int(gc.y)];
    }

    Cell get(int i, int j) {
        return cells[i][j];
    }

    PVector getCell(int x, int y) {
        return new PVector(int(y / cell_size) + 1, int(x / cell_size) + 1);
    }

    void setWall(int i1, int j1, int i2, int j2) {
        ArrayList cells = new ArrayList();
        if (abs(i1-i2) >= abs(j1-j2)) {
            for (int i = i1; i <= i2; i++) {
                get(i, j1).setWall(wall_gcs.size());
                cells.add(new PVector(i, j1));
            }
        } else {
            for (int j = j1; j <= j2; j++) {
                get(i1, j).setWall(wall_gcs.size());
                cells.add(new PVector(i1, j));
            }
        }
        wall_gcs.add(cells);
        wall_states.add(-1);
    }

    void setZones() {
        int zone_id = 0;
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                if (get(i, j).isZoneFree()) {
                    zoneFill(i, j, zone_id);
                    zone_id += 1;
                }
            }
        }
        //println("found " + zone_id + " zones");
    }

    // find distinct zones by flood filling
    void zoneFill(int i, int j, int zone_id) {
        get(i, j).zone_id = zone_id;
        if (i > 0 && get(i-1, j).isZoneFree()) {
            zoneFill(i-1, j, zone_id);
        } 
        if (i < n_rows+1 && get(i+1, j).isZoneFree()) {
            zoneFill(i+1, j, zone_id);            
        } 
        if (j > 0 && get(i, j-1).isZoneFree()) {
            zoneFill(i, j-1, zone_id);
        } 
        if (j < n_cols+1 && get(i, j+1).isZoneFree()) {
            zoneFill(i, j+1, zone_id);
        }
        
    }

    void showZones() {
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                get(i, j).setZoneColor();
            }
        }        
    }

    void setWallState(int wid, int state) {
        ArrayList cells = wall_gcs.get(wid);
        for (int i = 0; i < cells.size(); i++) {
            get((PVector)cells.get(i)).setWallState(state);
        }
        wall_states.set(wid, state);
    }

    int getWallState(int wid) {
        return wall_states.get(wid);
    }

    void resetWallStates() {
        for (int i = 0; i < wall_states.size(); i++) {
            wall_states.set(i, -1);
        }
    }

    void updateWallStates() {
        for (int i = 0; i < wall_states.size(); i++) {
            setWallState(i, wall_states.get(i));
        }
    }

    void reset() {
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                get(i, j).reset();
            }
        }
    }

}

class Cell {
    
    PVector pos;    
    int wall_id, wall_state, zone_id;
    boolean has_trace, has_cursor;

    Cell(float x, float y) {
        pos = new PVector(x, y);
        wall_id = -1; // -1: no wall, 0--n: walls
        wall_state = -1; // -1: not set, 0:bad, 1:good
        zone_id = -1; // -1: no zone, 0--n: zones
        has_trace = false;
        has_cursor = false;
        display();
    } 

    boolean isWall() {
        return wall_id >= 0;
    }

    boolean isZoneFree() {
        return !isWall() && zone_id < 0;
    }
   
    void setTrace(boolean b) {
        has_trace = b;
        display();
    }

    void setWall(int wid) {
        wall_id = wid;
        display();
    }

    void setWallState(int state) {
        wall_state = state;
        display();
    }

    void setCursor(boolean b) {
        has_cursor = b;
        display();
    }
     
    void reset() {
        has_trace = false;
        has_cursor = false;
        wall_state = -1;
        display();
    }

    void display() {
        stroke(127);
        if (has_cursor) {
            fill(255, 255, 0); // yellow
        } else if (has_trace) {
            fill(0, 0, 255); // blue
        } else if (isWall()) {
            if (wall_state == -1) {
                fill(255); // default wall: white
            } else if (wall_state == 0) {
                fill(255, 0, 0); // wall bad: red
            } else if (wall_state == 1) {
                fill(0, 255, 0); // wall ok: green
            }
        } else {
            fill(0);
        }
        rect(pos.x, pos.y, cell_size, cell_size);
    }

    void setZoneColor() {
        if (zone_id >= 0) {
            stroke(127);
            fill(0, (zone_id + 3) * 25, 0);        
            rect(pos.x, pos.y, cell_size, cell_size);
        }
    }

}

class Cursor {

    PVector curr_gc;
    boolean is_picked;
    int prev_zone_id;
    int curr_wall_id;
    ArrayList<PVector> trace_history;

    Cursor(PVector new_gc) {
        curr_gc = new_gc.get();        
        is_picked = false;
        prev_zone_id = -1;
        curr_wall_id = -1;
        trace_history = new ArrayList();
        set(true);
        //println("cursor (" + int(curr_gc.x) + "," + int(curr_gc.y) + ")");
    }

    void set(boolean b) {
        int i = int(curr_gc.x);
        int j = int(curr_gc.y);
        grid.get(i-1, j).setCursor(b);
        grid.get(i+1, j).setCursor(b);
        grid.get(i, j).setCursor(b);
        grid.get(i, j-1).setCursor(b);
        grid.get(i, j+1).setCursor(b);
    }

    void pick(PVector mouse_gc) {
        is_picked = (curr_gc.x-1 <= mouse_gc.x && mouse_gc.x <= curr_gc.x+1 &&
                     curr_gc.y-1 <= mouse_gc.y && mouse_gc.y <= curr_gc.y+1);
    }

    void move(PVector new_gc) {        
        int new_i = int(new_gc.x);
        int new_j = int(new_gc.y);
        if (eq(curr_gc, new_gc) || new_i < 1 || new_j < 1 ||
            new_i > grid.n_rows || new_j > grid.n_cols) { return; }
        //println("move (" + int(new_gc.x) + "," + int(new_gc.y) + ")");
        set(false);
        completeTrace(new_gc);
        curr_gc = new_gc.get();
        //println("curr (" + int(curr_gc.x) + "," + int(curr_gc.y) + ")");
        set(true);
    }

    void completeTrace(PVector new_gc) {
        // mid_gc is a vector that we'll move stepwise in the direction of new_gc
        PVector mid_gc = curr_gc.get();
        int N = int(max(abs(new_gc.x - mid_gc.x), abs(new_gc.y - mid_gc.y)));
        if (N >= 2) {
            grid.get(mid_gc).setTrace(true);
            trace_history.add(mid_gc.get());
            for (int n = 0; n < N; n++) {
                PVector d = new_gc.get();
                d.sub(mid_gc);
                d.normalize();
                mid_gc.add(d);
                mid_gc.x = round(mid_gc.x);
                mid_gc.y = round(mid_gc.y);
                grid.get(mid_gc).setTrace(true);
                //println("complete (" + int(mid_gc.x) + "," + int(mid_gc.y) + ")");
                detectWallCrossing(mid_gc);
                trace_history.add(mid_gc.get());
            }
        } else {
            detectWallCrossing(new_gc);
            grid.get(curr_gc).setTrace(true);
            trace_history.add(curr_gc.get());
        }
    }

    void detectWallCrossing(PVector new_gc) {
        if (grid.get(new_gc).isWall()) {
            if (curr_wall_id < 0) {
                //println("entering wall " + grid.get(i, j).wall_id + " at (" + i + "," + j + ")");
            }
            curr_wall_id = grid.get(new_gc).wall_id;
            if (grid.getWallState(curr_wall_id) != -1) { // if wall state is determined, we know
                grid.setWallState(curr_wall_id, 0);      // right away that it cannot be good anymore
            }
        } else {
            if (curr_wall_id >= 0) { // was in wall, got out
                //println("exiting wall " + curr_wall_id + " at (" + i + "," + j + ")");
                //println("prev zone = " + prev_zone_id + " , curr zone = " + grid.get(i, j).zone_id);
                if (grid.get(new_gc).zone_id != prev_zone_id && 
                    grid.getWallState(curr_wall_id) == -1) {
                    grid.setWallState(curr_wall_id, 1);
                } else {
                    grid.setWallState(curr_wall_id, 0);
                }
                curr_wall_id = -1;
            }
            prev_zone_id = grid.get(new_gc).zone_id;                
        }
    }

    void back(int n) {
        //if (trace_history.size() == 0) return;
        int m = min(n, trace_history.size());
        for (int i = 0; i < m; i++) {
            grid.get(curr_gc).setTrace(false);
            set(false);               
            PVector prev_gc = trace_history.get(trace_history.size()-1);
            curr_gc = prev_gc;
            set(true);
            trace_history.remove(trace_history.size()-1);
        }
        replayHistory();
    }

    void replayHistory() {
        grid.resetWallStates();
        curr_wall_id = -1;
        prev_zone_id = -1;
        for (int i = 0; i < trace_history.size(); i++) {
            detectWallCrossing(trace_history.get(i));
        }
        detectWallCrossing(cursor.curr_gc);
        grid.updateWallStates();
    }
    
}