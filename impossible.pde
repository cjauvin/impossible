Grid grid = null;
int width = 600;
int height = 500;
int cell_size = 5;
Cursor[] cursors = null;
int last_picked_cursor = -1;
int n_steps_back = 10;

void setup() {

    size(width, height);
    grid = new Grid(height / cell_size, width / cell_size);

    int nr = grid.n_rows;
    int nc = grid.n_cols;

    // square
    /*
    grid.addAnchor(nr/4+1, nc/4);
    grid.addAnchor(nr/4+1, nc/4*3+1);
    grid.addAnchor(nr/4*3+1, nc/4);
    grid.addAnchor(nr/4*3+1, nc/4*3+1);
    grid.addWall(0, 1);
    grid.addWall(1, 3);
    grid.addWall(3, 2);
    grid.addWall(2, 0);
    */

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
    grid.findZones();
    //grid.showZones();

    ArrayList<PVector> reset_btn_data = new ArrayList();
    reset_btn_data.add(new PVector(1, 3));
    reset_btn_data.add(new PVector(1, 4));
    reset_btn_data.add(new PVector(1, 6));
    reset_btn_data.add(new PVector(2, 2));
    reset_btn_data.add(new PVector(2, 5));
    reset_btn_data.add(new PVector(2, 6));
    reset_btn_data.add(new PVector(3, 1));
    reset_btn_data.add(new PVector(3, 4));
    reset_btn_data.add(new PVector(3, 5));
    reset_btn_data.add(new PVector(3, 6));
    reset_btn_data.add(new PVector(4, 1));
    reset_btn_data.add(new PVector(5, 2));
    reset_btn_data.add(new PVector(6, 3));
    reset_btn_data.add(new PVector(6, 4));
    reset_btn_data.add(new PVector(6, 5));   
    grid.addButton(reset_btn_data, new PVector(5, 5), 
                   new PVector(0, 200, 0), new PVector(0, 255, 0));

    ArrayList<PVector> back_btn_data = new ArrayList();
    back_btn_data.add(new PVector(1, 3));
    back_btn_data.add(new PVector(2, 2));
    back_btn_data.add(new PVector(3, 1));
    back_btn_data.add(new PVector(3, 2));
    back_btn_data.add(new PVector(3, 3));
    back_btn_data.add(new PVector(3, 4));
    back_btn_data.add(new PVector(3, 5));
    back_btn_data.add(new PVector(3, 6));
    back_btn_data.add(new PVector(4, 2));
    back_btn_data.add(new PVector(5, 3));    
    grid.addButton(back_btn_data, new PVector(5, grid.n_cols - 15), 
                   new PVector(0, 0, 200), new PVector(0, 0, 255));

}

void draw() {
    grid.updateButtonTimer();
}

void reset() {
    cursors = null;
    grid.reset();
}

void mousePressed() {
    if (mouseButton == LEFT) {
        PVector mouse_gc = grid.getCell(mouseX, mouseY);
        if (cursors == null && grid.get(mouse_gc).isStartable()) {
            cursors = new Cursor[2];
            cursors[0] = new Cursor(mouse_gc);
            cursors[1] = new Cursor(mouse_gc);
        }
        if (cursors != null) {
            if (cursors[0].pick(mouse_gc)) {
                last_picked_cursor = 0;
            } else if (cursors[1].pick(mouse_gc)) {
                last_picked_cursor = 1;
            } else {
                int btn_id = grid.buttonClicked(mouse_gc);
                if (btn_id == 0) {
                    grid.pushButton(0);
                    reset();
                } else if (btn_id == 1) {
                    grid.pushButton(1);
                    cursors[last_picked_cursor].back(n_steps_back);                    
                }
            }

        }        
    } else if (mouseButton == RIGHT) {
        if (cursors != null) {
            cursors[last_picked_cursor].back(n_steps_back);
        }        
    }
}

//void mouseMoved() {    
void mouseDragged() {
    if (cursors != null) {
        if (cursors[0].is_picked) {
            cursors[0].move(grid.getCell(mouseX, mouseY));
        } else if (cursors[1].is_picked) {
            cursors[1].move(grid.getCell(mouseX, mouseY));
        }
     }
}

void mouseReleased() {
    if (cursors != null) {
        cursors[0].is_picked = false;
        cursors[1].is_picked = false;
    }
}

void keyPressed() {
    if (key == 'r') {
        grid.pushButton(0);
        reset();
    } else if (key == 'b') {
        if (cursors != null) {
            grid.pushButton(1);
            cursors[last_picked_cursor].back(n_steps_back);
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
    ArrayList<ArrayList> button_data;
    int btn_timer_started_at, btn_timer_delay, btn_timer_id;

    Grid(int nr, int nc) {
        n_rows = nr;
        n_cols = nc;
        wall_gcs = new ArrayList();
        wall_states = new ArrayList();
        anchor_gcs = new ArrayList();
        cells = new Cell[n_rows + 2][n_cols + 2]; // add 6-cell padding to each side
        button_data = new ArrayList();
        btn_timer_started_at = -1;
        btn_timer_delay = 50;
        btn_timer_id = -1;
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

    // 8x8 button with 10x10 frame
    void addButton(ArrayList<PVector> data, PVector topleft_gc, PVector col, PVector pcol) {
        int btn_id = button_data.size();
        int top = int(topleft_gc.x);
        int left = int(topleft_gc.y);
        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                if (i == 0 || i == 9 || j == 0 || j == 9) {
                    data.add(new PVector(i-1, j-1));
                } else {
                    get(top + i, left + j).setButton(btn_id, null, null);
                }
            }
        }
        //button_data.add(data);
        ArrayList<PVector> updated_data = new ArrayList();
        for (int i = 0; i < data.size(); i++) {
            PVector gc = data.get(i);
            gc.x += (top + 2);
            gc.y += (left + 2);
            get(gc).setButton(btn_id, col, pcol);
            updated_data.add(gc);
        }        
        button_data.add(updated_data);
    }

    void updateButton(int btn_id, boolean is_pushed) {
        ArrayList<PVector> data = button_data.get(btn_id);
        for (int i = 0; i < data.size(); i++) {
            grid.get(data.get(i)).pushButton(is_pushed);
        }
    }

    int buttonClicked(PVector mouse_gc) {
        return get(mouse_gc).button_id;        
    }

    void pushButton(int btn_id) {
        updateButton(btn_id, true);
        startButtonTimer(btn_id);
    }
    
    void startButtonTimer(int btn_id) {
        btn_timer_started_at = millis();
        btn_timer_id = btn_id;
    }

    void updateButtonTimer() {
        if (btn_timer_started_at > 0) {
            if (millis() - btn_timer_started_at >= btn_timer_delay) {
                updateButton(btn_timer_id, false);
                btn_timer_started_at = -1;
                btn_timer_id = -1;
            }
        }
    }

    // a wall links an anchor to an other (they must be on same row or col)
    void addWall(int a1, int a2) {
        ArrayList wall_cells = new ArrayList();
        PVector a1_gc = anchor_gcs.get(a1);
        PVector a2_gc = anchor_gcs.get(a2);
        //assert(a1_gc.x == a2_gc.x || a1_gc.y == a2_gc.y);
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

    void findZones() {
        int zone_id = 0;
        for (int i = 0; i < n_rows + 2; i++) {
            for (int j = 0; j < n_cols + 2; j++) {
                if (get(i, j).isZoneFree()) {
                    zoneFill(new PVector(i, j), zone_id);
                    zone_id += 1;
                }
            }
        }
        //println("found " + zone_id + " zones");
    }

    // find distinct zones by flood filling
    void zoneFill(PVector start_gc, int zone_id) {
        ArrayList<PVector> frontier = new ArrayList();
        frontier.add(start_gc);
        while (frontier.size() > 0) {
            PVector gc = frontier.remove(0);
            if (!get(gc).isZoneFree()) continue;
            int i = int(gc.x);
            int j = int(gc.y);
            get(i, j).zone_id = zone_id;
            if (i > 0 && get(i-1, j).isZoneFree()) {
                frontier.add(new PVector(i-1, j));
            } 
            if (i < n_rows+1 && get(i+1, j).isZoneFree()) {
                frontier.add(new PVector(i+1, j));
            } 
            if (j > 0 && get(i, j-1).isZoneFree()) {
                frontier.add(new PVector(i, j-1));
            } 
            if (j < n_cols+1 && get(i, j+1).isZoneFree()) {
                frontier.add(new PVector(i, j+1));
            }     
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
    int wall_id, wall_state, zone_id, anchor_id, button_id;
    boolean has_trace, has_cursor, is_button_pushed;
    PVector button_color, button_push_color;

    Cell(float x, float y) {
        pos = new PVector(x, y);
        wall_id = -1; // -1: no wall, 0--n: walls
        wall_state = -1; // -1: not set, 0:bad, 1:good
        zone_id = -1; // -1: no zone, 0--n: zones
        anchor_id = -1; // -1: no anchor
        button_id = -1; // -1: no button
        has_trace = false;
        has_cursor = false;
        button_color = null;
        button_push_color = null;
        is_button_pushed = false;
        display();
    } 

    boolean isStartable() {
        return !isWall() && !isAnchor() && !isButton();
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

    void setButton(int id, PVector col, PVector push_col) {
        button_id = id;
        button_color = col;
        button_push_color = push_col;
        display();
    }

    boolean isButton() {
        return button_id >= 0;
    }

    void pushButton(boolean b) {
        is_button_pushed = b;
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
        } else if (isButton() && button_color != null) {
            if (is_button_pushed) {
                fill(button_push_color.x, button_push_color.y, button_push_color.z);
            } else {
                fill(button_color.x, button_color.y, button_color.z);
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

    boolean pick(PVector mouse_gc) {
        is_picked = (curr_gc.x-1 <= mouse_gc.x && mouse_gc.x <= curr_gc.x+1 &&
                     curr_gc.y-1 <= mouse_gc.y && mouse_gc.y <= curr_gc.y+1);
        return is_picked;
    }

    void move(PVector new_gc) {        
        int new_i = int(new_gc.x);
        int new_j = int(new_gc.y);
        if (eq(curr_gc, new_gc)) { // below cell size threshold
            return;
        }
        // detect boundaries and anchor cells
        if (new_i < 1 || new_j < 1 || new_i > grid.n_rows || 
            new_j > grid.n_cols || grid.get(new_gc).isAnchor() ||
            grid.get(new_gc).isButton()) { 
            is_picked = false;
            return; 
        }
        // dist with curr cell; n=1 -> adjacent move (no need to interpolate)
        int n = int(max(abs(new_gc.x - curr_gc.x), abs(new_gc.y - curr_gc.y)));
        PVector mid_gc = curr_gc.get(); // mid_gc is a vector that we'll move stepwise in the direction of new_gc
        ArrayList<PVector> mid_gcs = new ArrayList();
        mid_gcs.add(mid_gc.get());
        for (int i = 0; i < n-1; i++) { // interpolation
            PVector d = new_gc.get();
            d.sub(mid_gc);
            d.normalize();
            mid_gc.add(d);
            mid_gc.x = round(mid_gc.x);
            mid_gc.y = round(mid_gc.y);
            if (grid.get(mid_gc).isAnchor()) {
                is_picked = false;
                return;
            }
            mid_gcs.add(mid_gc.get());
        }
        for (int i = 0; i < mid_gcs.size(); i++) {
            mid_gc = mid_gcs.get(i);
            grid.get(mid_gc).setTrace(true);
            detectWallCrossing(mid_gc);
            trace_history.add(mid_gc.get());
        } 
        detectWallCrossing(new_gc);
        set(false);
        curr_gc = new_gc.get();
        cursors[0].set(true);
        cursors[1].set(true);
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
        int m = min(n, trace_history.size());
        for (int i = 0; i < m; i++) {
            grid.get(curr_gc).setTrace(false);
            set(false);               
            PVector prev_gc = trace_history.get(trace_history.size()-1);
            curr_gc = prev_gc;
            set(true);
            trace_history.remove(trace_history.size()-1);
        }
        grid.resetWallStates();
        cursors[0].replayHistory();
        cursors[1].replayHistory();
    }

    void replayHistory() {
        curr_wall_id = -1;
        prev_zone_id = -1;
        for (int i = 0; i < trace_history.size(); i++) {
            detectWallCrossing(trace_history.get(i));
            grid.get(trace_history.get(i)).setTrace(true);
        }
        detectWallCrossing(curr_gc);
        grid.updateWallStates();
    }
    
}
