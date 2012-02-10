Grid grid = null;
int width = 600;
int height = 600;
int cell_size = 6;
Cursor cursor = null;

void setup() {
    size(width, height);
    grid = new Grid(width / cell_size, height / cell_size);
    grid.setWall(grid.n_rows/4, grid.n_cols/4, grid.n_rows/4, grid.n_cols/4*3);
    grid.setWall(grid.n_rows/4, grid.n_cols/4, grid.n_rows/4*3, grid.n_cols/4);
    grid.setWall(grid.n_rows/4, grid.n_cols/4*3, grid.n_rows/4*3, grid.n_cols/4*3);
    grid.setWall(grid.n_rows/4*3, grid.n_cols/4, grid.n_rows/4*3, grid.n_cols/4*3);
    grid.setZones();
    //grid.showZones();
}

void draw() {
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

boolean eq(PVector v1, PVector v2) {
    return (v1.x == v2.x && v1.y == v2.y && v1.z == v2.z);
}

class Grid {

    Cell[][] cells;
    int n_rows, n_cols;
    ArrayList wall_gcs, wall_states; 

    Grid(int nr, int nc) {
        n_rows = nr;
        n_cols = nc;
        wall_gcs = new ArrayList();
        wall_states = new ArrayList();
        cells = new Cell[n_cols + 2][n_rows + 2]; // add 6-cell padding to each side
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
        ArrayList cells = (ArrayList)wall_gcs.get(wid);
        for (int i = 0; i < cells.size(); i++) {
            get((PVector)cells.get(i)).setWallState(state);
        }
        wall_states.set(wid, state);
    }

    int getWallState(int wid) {
        return (Integer)wall_states.get(wid);
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
   
    void setTrace() {
        has_trace = true;
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

    PVector gc, last_gc;
    boolean is_picked;
    int prev_zone_id;
    int curr_wall_id;

    Cursor(PVector new_gc) {
        gc = new_gc.get();        
        last_gc = gc.get();
        is_picked = false;
        prev_zone_id = -1;
        curr_wall_id = -1;
        set();
    }

    void set() {
        int i = int(gc.x);
        int j = int(gc.y);
        grid.get(i-1, j).setCursor(true);
        grid.get(i+1, j).setCursor(true);
        grid.get(i, j).setCursor(true);
        grid.get(i, j-1).setCursor(true);
        grid.get(i, j+1).setCursor(true);
    }

    void move(PVector new_gc) {
        if (eq(gc, new_gc)) return;
        int i = int(gc.x);
        int j = int(gc.y);
        grid.get(i-1, j).setCursor(false);
        grid.get(i+1, j).setCursor(false);
        grid.get(i, j).setCursor(false);
        grid.get(i, j-1).setCursor(false);
        grid.get(i, j+1).setCursor(false);
        last_gc = gc.get();
        gc = new_gc.get();
        completeTrace();
        set();
    }

    void pick(PVector mouse_gc) {
        is_picked = (gc.x-1 <= mouse_gc.x && mouse_gc.x <= gc.x+1 &&
                     gc.y-1 <= mouse_gc.y && mouse_gc.y <= gc.y+1);
    }

    void completeTrace() {
        PVector p = last_gc.get();
        int N = int(max(abs(gc.x - last_gc.x), abs(gc.y - last_gc.y)));
        for (int n = 0; n < N; n++) {
            PVector d = gc.get();
            d.sub(p);
            d.normalize();
            p.add(d);
            int i = int(round(p.x));
            int j = int(round(p.y));
            grid.get(i, j).setTrace();
            detectWallCrossing(i, j);
        }
    }

    void detectWallCrossing(int i, int j) {
        if (grid.get(i, j).isWall()) {
            if (curr_wall_id < 0) {
                //println("entering wall " + grid.get(i, j).wall_id + " at (" + i + "," + j + ")");
            }
            curr_wall_id = grid.get(i, j).wall_id;
        } else {
            if (curr_wall_id >= 0) { // was in wall, got out
                //println("exiting wall " + curr_wall_id + " at (" + i + "," + j + ")");
                if (grid.get(i, j).zone_id != prev_zone_id && 
                    grid.getWallState(curr_wall_id) == -1) {
                    grid.setWallState(curr_wall_id, 1);
                } else {
                    grid.setWallState(curr_wall_id, 0);
                }
                curr_wall_id = -1;
                prev_zone_id = grid.get(i, j).zone_id;                
            }
        }
    }

}