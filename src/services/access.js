const HttpError = require('../utils/http-error');
const { ROLES } = require('../config/roles');

// U1 chỉ được thao tác trên thiết bị của khoa mình (Bảng 2.4).
function assertDepartmentAccess(user, equipment) {
    if (user.role === ROLES.DEPARTMENT && Number(user.department_id) !== Number(equipment.department_id)) {
        throw new HttpError(403, 'Thiết bị không thuộc khoa của bạn');
    }
}

function departmentScope(user) {
    return user && user.role === ROLES.DEPARTMENT ? user.department_id : null;
}

async function loadEquipment(equipmentRepository, id) {
    const equipment = await equipmentRepository.findBasic(id);
    if (!equipment) throw new HttpError(404, 'Không tìm thấy thiết bị');
    return equipment;
}

module.exports = { assertDepartmentAccess, departmentScope, loadEquipment };
