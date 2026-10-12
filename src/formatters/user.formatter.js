function formatUser(row) {
    const name = row.name ? String(row.name) : 'User';
    const avatar = `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&color=7F9CF5&background=EBF4FF`;

    return {
        id: parseInt(row.id) || 0,
        name,
        email: row.email ? String(row.email) : '',
        email_verified_at: null,
        current_team_id: null,
        displayname: row.displayname ? String(row.displayname) : name,
        image: row.profile_photo_url ? String(row.profile_photo_url) : null,
        address: row.address ? String(row.address) : null,
        birthday: row.birthday ? String(row.birthday) : null,
        phone: row.phone ? String(row.phone) : '',
        department_id: parseInt(row.department_id) || 0,
        gender: row.gender ? String(row.gender) : 'Nam',
        is_disabled: parseInt(row.is_disabled) || 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        profile_photo_url: row.profile_photo_url ? String(row.profile_photo_url) : avatar
    };
}

module.exports = formatUser;
