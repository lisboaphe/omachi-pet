// Hyprland IPC at/size are logical desktop coordinates, not physical pixels.
function build(clients, monitor, width, height) {
    if(!monitor)return {width:width,floor:height-8,platforms:[],blocked:false};
    var floor=height-Math.max(8,Number((monitor.reserved||[])[3])||0);
    var ws=monitor.activeWorkspace ? monitor.activeWorkspace.id : -1;
    var visible=clients.filter(function(c){return c.mapped!==false&&!c.hidden&&c.workspace&&c.workspace.id===ws&&c.monitor===monitor.id;});
    var blocked=visible.some(function(c){return !!c.fullscreen;}) || !!(monitor.specialWorkspace&&monitor.specialWorkspace.id);
    var platforms=[];
    visible.forEach(function(c){
        if(!c.at||!c.size||c.size[0]<72||c.size[1]<32)return;
        var x1=Math.max(0,c.at[0]-monitor.x),x2=Math.min(width,c.at[0]-monitor.x+c.size[0]),y=c.at[1]-monitor.y;
        if(y<90||y>floor-40||x2-x1<72)return;
        // Conservatively omit any top crossed by another window, independent of stacking.
        var covered=visible.some(function(o){return o!==c&&o.at&&o.size&&o.at[1]<c.at[1]&&o.at[1]+o.size[1]>c.at[1]&&o.at[0]<c.at[0]+c.size[0]&&o.at[0]+o.size[0]>c.at[0];});
        if(!covered)platforms.push({id:c.address,x1:x1,x2:x2,y:y,bottom:c.at[1]-monitor.y+c.size[1]});
    });
    return {width:width,floor:floor,platforms:blocked?[]:platforms,blocked:blocked};
}
