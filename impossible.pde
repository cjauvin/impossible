Grid grid = null;
int width = 600;
int height = 600;
int cell_size = 5;
Cursor cursor = null;

void setup() {
    size(width, height);
    grid = new Grid(width / cell_size, height / cell_size);

    // square
    // grid.addAnchor(grid.n_rows/4, grid.n_cols/4);
    // grid.addAnchor(grid.n_rows/4, grid.n_cols/4*3);
    // grid.addAnchor(grid.n_rows/4*3, grid.n_cols/4);
    // grid.addAnchor(grid.n_rows/4*3, grid.n_cols/4*3);
    // grid.addWall(0, 1);
    // grid.addWall(1, 3);
    // grid.addWall(3, 2);
    // grid.addWall(2, 0);
    
    int nr = grid.n_rows;
    int nc = grid.n_cols;
    grid.addAnchor(1 + nr/4, 1 + nc/8);
    grid.addAnchor(1 + nr/4, 1 + nc/8 + nc/8*3);
    grid.addAnchor(1 + nr/4, 1 + nc/8 + 2 * nc/8*3);
    grid.addAnchor(1 + 2 * nr/4, 1 + nc/8);
    grid.addAnchor(1 + 2 * nr/4, 1 + nc/8 + int(nc*3/16));
    grid.addAnchor(1 + 2 * nr/4, 1 + nc/8 + nc/8*3);
    grid.addAnchor(1 + 2 * nr/4, 1 + nc/8 + nc/8*3 + int(nc*3/16));
    grid.addAnchor(1 + 2 * nr/4, 1 + nc/8 + 2 * nc/8*3);
    grid.addAnchor(1 + 3 * nr/4, 1 + nc/8);
    grid.addAnchor(1 + 3 * nr/4, 1 + nc/8 + int(nc*3/16));
    grid.addAnchor(1 + 3 * nr/4, 1 + nc/8 + nc/8*3 + int(nc*3/16));
    grid.addAnchor(1 + 3 * nr/4, 1 + nc/8 + 2 * nc/8*3);
   
    grid.addWall(0, 1);
    grid.addWall(1, 2);
    grid.addWall(0, 3);
    grid.addWall(1, 5);
    grid.addWall(2, 7);
    grid.addWall(3, 4);
    grid.addWall(4, 5);
    grid.addWall(5, 6);
    grid.addWall(6, 7);
    grid.addWall(3, 8);
    grid.addWall(4, 9);
    grid.addWall(6, 10);
    grid.addWall(7, 11);
    grid.addWall(8, 9);
    grid.addWall(9, 10);
    grid.addWall(10, 11);
    
    grid.finalizeWallAnchors();

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
    if (mouseButton == LEFT) {
        PVector mouse_gc = grid.getCell(mouseX, mouseY);
        if (cursor == null && grid.get(mouse_gc).isStartable()) {
            cursor = new Cursor(mouse_gc);
        }
        if (cursor != null) {
            cursor.pick(mouse_gc);
        }
    } else if (mouseButton == RIGHT) {
        if (cursor != null) {
            cursor.back(10);
        }        
    }
}

void mouseDragged() {    
    if (cursor != null && cursor.is_picked) {
        cursor.move(grid.getCell(mouseX, mouseY));
    }
}

void mouseReleased() {
    if (cursor != null) {
        cursor.is_picked = false;
    }
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
    ArrayList<PVector> anchor_gcs;

    Grid(int nr, int nc) {
        n_rows = nr;
        n_cols = nc;
        wall_gcs = new ArrayList();
        wall_states = new ArrayList();
        anchor_gcs = new ArrayList();
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

    // a wall links an anchor to an other (they must be on same row or col)
    void addWall(int a1, int a2) {
        ArrayList wall_cells = new ArrayList();
        PVector a1_gc = anchor_gcs.get(a1);
        PVector a2_gc = anchor_gcs.get(a2);
        assert(a1_gc.x == a2_gc.x || a1_gc.y == a2_gc.y);
        if (abs(a1_gc.x - a2_gc.x) > abs(a1_gc.y - a2_gc.y)) {
            if (a1_gc.x > a2_gc.x) { // swap
                PVector tmp = a1_gc;
                a1_gc = a2_gc;
                a2_gc = tmp;
            }
            int j = int(a1_gc.y);
            for (int i = int(a1_gc.x)+1; i < int(a2_gc.x); i++) {
                get(i, j).setWall(wall_gcs.size());
                wall_cells.add(new PVector(i, j));
            }            
        } else {
            if (a1_gc.y > a2_gc.y) { // swap
                PVector tmp = a1_gc;
                a1_gc = a2_gc;
                a2_gc = tmp;
            }
            int i = int(a1_gc.x);
            for (int j = int(a1_gc.y)+1; j < int(a2_gc.y); j++) {
                get(i, j).setWall(wall_gcs.size());
                wall_cells.add(new PVector(i, j));
            }
        }
        wall_gcs.add(wall_cells);
        wall_states.add(-1);
    }

    void addAnchor(int i, int j) {
        get(i, j).setAnchor(anchor_gcs.size());
        anchor_gcs.add(new PVector(i, j));
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
        int max_zone_id = -1;
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                get(i, j).setZoneColor();
                max_zone_id = max(max_zone_id, get(i, j).zone_id);
            }
        }
        println("found " + (max_zone_id+1) + " zones");
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

    void updateWallStates() {
        for (int i = 0; i < wall_states.size(); i++) {
            setWallState(i, wall_states.get(i));
        }
    }

    void resetWallStates() {
        for (int i = 0; i < wall_states.size(); i++) {
            wall_states.set(i, -1);
        }
    }

    void reset() {
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                get(i, j).reset();
            }
        }
        resetWallStates();
    }

    // for each wall, set first and last cell as anchors
    void finalizeWallAnchors() {
        int anchor_id = anchor_gcs.size();
        for (int i = 0; i < wall_gcs.size(); i++) {
            ArrayList<PVector> gcs = wall_gcs.get(i);
            get(gcs.get(0)).setAnchor(anchor_id++);
            get(gcs.get(gcs.size()-1)).setAnchor(anchor_id++);            
        }
    }

}

class Cell {
    
    PVector pos;    
    int wall_id, wall_state, zone_id, anchor_id;
    boolean has_trace, has_cursor;

    Cell(float x, float y) {
        pos = new PVector(x, y);
        wall_id = -1; // -1: no wall, 0--n: walls
        wall_state = -1; // -1: not set, 0:bad, 1:good
        zone_id = -1; // -1: no zone, 0--n: zones
        anchor_id = -1;
        has_trace = false;
        has_cursor = false;
        display();
    } 

    boolean isStartable() {
        return !isWall() && !isAnchor();
    }

    boolean isWall() {
        return wall_id >= 0;
    }

    boolean isAnchor() {
        return anchor_id >= 0;
    }

    void setAnchor(int id) {
        anchor_id = id;
        display();
    }

    boolean isZoneFree() {
        return !isWall() && zone_id < 0 && !isAnchor();
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
        stroke(80); // grey outline
        if (has_cursor) {
            fill(255, 255, 0); // yellow
        } else if (has_trace) {
            fill(0, 0, 255); // blue
        } else if (isAnchor()) {
            fill(127); // grey
        } else if (isWall()) {
            if (wall_state == -1) {
                fill(225); // wall default: white
            } else if (wall_state == 0) {
                fill(255, 0, 0); // wall bad: red
            } else if (wall_state == 1) {
                fill(0, 255, 0); // wall ok: green
            }
        } else {
            fill(0); // black
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
        if (eq(curr_gc, new_gc)) {
            return;
        }
        if (new_i < 1 || new_j < 1 || new_i > grid.n_rows || 
            new_j > grid.n_cols || grid.get(new_gc).isAnchor()) { 
            is_picked = false;
            return; 
        }
        if (completeTrace(new_gc)) {
            set(false);
            curr_gc = new_gc.get();
            set(true);
        }
    }

    boolean completeTrace(PVector new_gc) {
        // mid_gc is a vector that we'll move stepwise in the direction of new_gc
        PVector mid_gc = curr_gc.get();
        int N = int(max(abs(new_gc.x - mid_gc.x), abs(new_gc.y - mid_gc.y)));
        if (N >= 2) {
            ArrayList<PVector> mid_gcs = new ArrayList();
            mid_gcs.add(mid_gc.get());
            for (int n = 0; n < N; n++) {
                PVector d = new_gc.get();
                d.sub(mid_gc);
                d.normalize();
                mid_gc.add(d);
                mid_gc.x = round(mid_gc.x);
                mid_gc.y = round(mid_gc.y);
                if (grid.get(mid_gc).isAnchor()) {
                    is_picked = false;
                    return false;
                }
                mid_gcs.add(mid_gc.get());
            }
            for (int i = 0; i < mid_gcs.size(); i++) {
                mid_gc = mid_gcs.get(i);
                grid.get(mid_gc).setTrace(true);
                detectWallCrossing(mid_gc);
                trace_history.add(mid_gc.get());                
            } 
        } else {
            detectWallCrossing(new_gc);
            grid.get(curr_gc).setTrace(true);
            trace_history.add(curr_gc.get());
        }
        return true;
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
                //println("prev zone = " + prev_zone_id + " , curr zone = " + grid.get(new_gc).zone_id);
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
            grid.get(trace_history.get(i)).setTrace(true);
        }
        detectWallCrossing(cursor.curr_gc);
        grid.updateWallStates();
    }
    
}