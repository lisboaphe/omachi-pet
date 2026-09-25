import QtQuick
import "ui"
PetController {
    id: root
    PetPanel { service:root; screen:root.selectedScreen; visible:root.panelOpen }
    PetOverlay { service:root; screen:root.selectedScreen; visible:root.roaming&&root.ready&&root.pet.stage===1 }
}
