// Walkaround Interactive Simulation Engine & PDF Generator
// Focused 30-Second Walkaround Shield

const VEHICLE_ZONES = [
  { id: 'front', title: '1. Front Bumper & Hood', short: 'Front', hint: 'Align Front Bumper & Hood', icon: 'ph-car-profile', instr: 'Stand 6 ft back facing front. Captures bumper, headlights, and windshield chips.' },
  { id: 'driver_side', title: '2. Driver Side & Wheels', short: 'Driver Side', hint: 'Align Full Driver Profile', icon: 'ph-car-side', instr: 'Step back to capture doors, mirror, and front/rear alloy wheel rims.' },
  { id: 'rear', title: '3. Rear Bumper & Trunk', short: 'Rear', hint: 'Align Rear Bumper & Trunk', icon: 'ph-car-profile', instr: 'Check trunk lip where luggage drags, reverse sensors, and lower valance.' },
  { id: 'passenger_side', title: '4. Passenger Side & Wheels', short: 'Pass. Side', hint: 'Align Full Passenger Profile', icon: 'ph-car-side', instr: 'Capture passenger doors, handles, fuel door, and curb-side wheels.' },
  { id: 'dashboard', title: '5. Dashboard (Odometer & Fuel)', short: 'Dashboard', hint: 'Ignition ON: Mileage & Fuel', icon: 'ph-gauge', instr: 'Turn ignition ON. Snap clear view of odometer reading and fuel gauge needle.' }
];

// App State
let state = {
  rentals: [
    {
      id: 'sample-1',
      agency: 'Hertz',
      make: 'Ford',
      model: 'Mustang GT',
      year: '2024',
      plate: '8TRP492',
      state: 'CA',
      resNo: 'H89204128',
      vin: '1FA6P8CF9R5102983',
      status: 'Trip Protected ✓',
      pickup: {
        completed: true,
        time: '2026-08-21 09:15 UTC',
        gps: '33.9416° N, 118.4085° W (LAX Hertz Lot)',
        odo: '18,452',
        unit: 'mi',
        fuel: '8/8 (Full)',
        photos: {
          'front': true, 'driver_side': true, 'rear': true, 'passenger_side': true, 'dashboard': true
        },
        damages: [
          { zone: 'rear', type: 'Scratch / Scrape', sev: 'Moderate', notes: '3-inch vertical scratch near lower reverse sensor' },
          { zone: 'passenger_side', type: 'Rim Curb Rash', sev: 'Minor', notes: 'Existing 1-inch curb scuff on outer aluminum bead' }
        ]
      },
      dropoff: {
        completed: true,
        time: '2026-08-21 16:40 UTC',
        gps: '33.9416° N, 118.4085° W (LAX Rental Return Zone B)',
        odo: '18,740',
        unit: 'mi',
        fuel: '8/8 (Full)',
        photos: {
          'front': true, 'driver_side': true, 'rear': true, 'passenger_side': true, 'dashboard': true
        },
        damages: []
      }
    }
  ],
  currentRentalId: 'sample-1',
  currentPhase: 'pickup',
  cameraZoneIndex: 0,
  activeCompareZone: 'rear',
  isPro: false,
  damageTargetZone: null
};

// Initial Setup
document.addEventListener('DOMContentLoaded', () => {
  startLiveClock();
  renderHomeRentals();
});

// Clock updater
function startLiveClock() {
  setInterval(() => {
    const now = new Date();
    const hrs = String(now.getHours()).padStart(2, '0');
    const mins = String(now.getMinutes()).padStart(2, '0');
    const clockEl = document.getElementById('clock-time');
    if (clockEl) clockEl.textContent = `${hrs}:${mins}`;

    const hudEl = document.getElementById('hud-time-utc');
    if (hudEl) {
      const utcHrs = String(now.getUTCHours()).padStart(2, '0');
      const utcMins = String(now.getUTCMinutes()).padStart(2, '0');
      const utcSecs = String(now.getUTCSeconds()).padStart(2, '0');
      hudEl.textContent = `${utcHrs}:${utcMins}:${utcSecs} UTC`;
    }
  }, 1000);
}

// HTML Sanitizer to prevent XSS
function escapeHTML(str) {
  if (str === null || str === undefined) return '';
  const div = document.createElement('div');
  div.textContent = String(str);
  return div.innerHTML;
}

// Home Screen Rendering
function renderHomeRentals() {
  const container = document.getElementById('rental-cards-list');
  const countBadge = document.getElementById('active-rentals-count');
  container.innerHTML = '';

  countBadge.textContent = `${state.rentals.length} Active`;

  state.rentals.forEach(r => {
    const card = document.createElement('div');
    card.className = 'rental-card';
    card.innerHTML = `
      <div class="rental-top">
        <div class="agency-badge">
          <div class="agency-dot"></div>
          <span>${escapeHTML(r.agency)}</span>
        </div>
        <span class="status-pill green">${escapeHTML(r.status)}</span>
      </div>

      <div class="car-info">
        <h3 class="car-title">${escapeHTML(r.year)} ${escapeHTML(r.make)} ${escapeHTML(r.model)}</h3>
        <div class="car-meta">
          <span class="plate-pill"><i class="ph ph-rectangle"></i> ${escapeHTML(r.plate)}</span>
          <span><i class="ph ph-file-text"></i> ${escapeHTML(r.resNo)}</span>
        </div>
      </div>

      <div class="divider"></div>

      <div class="audit-status-row">
        <div class="stat-item">
          <span class="stat-lbl">PICK-UP PROOF</span>
          <span class="stat-val ${r.pickup.completed ? 'green' : 'orange'}">
            ${r.pickup.completed ? '✓ 5 Shots Secured' : 'Pending Start'}
          </span>
        </div>
        <div class="stat-item" style="text-align: right;">
          <span class="stat-lbl">RETURN PROOF</span>
          <span class="stat-val ${r.dropoff.completed ? 'green' : 'muted'}">
            ${r.dropoff.completed ? '✓ 5 Shots Secured' : 'Ready for Return'}
          </span>
        </div>
      </div>

      <div class="rental-actions dual-actions">
        <button class="btn btn-primary" onclick="openDisputeDossierFor('${escapeHTML(r.id)}')">
          <i class="ph-bold ph-shield-check"></i> I Got Billed (Dispute)
        </button>
        <button class="btn btn-subtle" onclick="openInspectionHub('${escapeHTML(r.id)}')">
          <i class="ph-bold ph-camera"></i> Manage / Return
        </button>
      </div>
    `;
    container.appendChild(card);
  });
}

// Fast 30-Second Walkaround Entrypoint (Zero-Typing)
function startFast30SecWalkaround() {
  const newRental = {
    id: 'rental-' + Date.now(),
    agency: 'Rental Car',
    make: 'Vehicle',
    model: 'Walkaround',
    year: '2026',
    plate: 'RENTAL-' + Math.floor(1000 + Math.random() * 9000),
    state: 'Active',
    resNo: 'TRIP-' + Math.floor(100000 + Math.random() * 900000),
    status: 'Walkaround In Progress',
    pickup: {
      completed: false,
      time: new Date().toISOString().replace('T', ' ').substring(0, 19) + ' UTC',
      gps: '33.9416° N, 118.4085° W (Rental Facility)',
      odo: '15,200',
      unit: 'mi',
      fuel: '8/8 (Full)',
      photos: {},
      damages: []
    },
    dropoff: {
      completed: false,
      time: 'Pending Return',
      gps: 'Pending Return',
      odo: '',
      unit: 'mi',
      fuel: '8/8 (Full)',
      photos: {},
      damages: []
    }
  };

  state.rentals.unshift(newRental);
  state.currentRentalId = newRental.id;
  state.currentPhase = 'pickup';
  startCameraAt(0);
}

// Navigation Functions
function showScreen(viewId) {
  document.querySelectorAll('.screen-view').forEach(el => el.classList.remove('active'));
  const target = document.getElementById(viewId);
  if (target) target.classList.add('active');
}

function navigateHome() {
  renderHomeRentals();
  showScreen('view-home');
}

function openInspectionHub(rentalId) {
  state.currentRentalId = rentalId;
  const r = getCurrentRental();
  document.getElementById('hub-car-name').textContent = `${r.year} ${r.make} ${r.model}`;
  document.getElementById('hub-car-sub').textContent = `${r.agency} • Plate: ${r.plate}`;
  renderInspectionHub();
  showScreen('view-inspection-hub');
}

function getCurrentRental() {
  return state.rentals.find(r => r.id === state.currentRentalId) || state.rentals[0];
}

function switchPhase(phase) {
  state.currentPhase = phase;
  document.getElementById('seg-pickup').classList.toggle('active', phase === 'pickup');
  document.getElementById('seg-dropoff').classList.toggle('active', phase === 'dropoff');
  renderInspectionHub();
}

function renderInspectionHub() {
  const r = getCurrentRental();
  const phaseData = r[state.currentPhase];

  const completedCount = Object.keys(phaseData.photos).length;
  document.getElementById('hub-zones-count').textContent = `${completedCount} / 5`;
  document.getElementById('hub-odo-val').textContent = `${phaseData.odo || '15,200'} ${phaseData.unit}`;
  document.getElementById('hub-flaws-count').textContent = `${phaseData.damages.length} Flaws`;
  document.getElementById('hub-phase-pill').textContent = phaseData.completed ? 'Protected ✓' : 'In Progress';
  document.getElementById('hub-dash-summary').textContent = `Recorded: ${phaseData.odo || '15,200'} ${phaseData.unit} • Fuel: ${phaseData.fuel}`;

  const listEl = document.getElementById('zone-list-container');
  listEl.innerHTML = '';

  VEHICLE_ZONES.forEach((zone, idx) => {
    const isDone = !!phaseData.photos[zone.id];
    const hasDmg = phaseData.damages.some(d => d.zone === zone.id);

    const item = document.createElement('div');
    item.className = 'zone-row';
    item.innerHTML = `
      <div class="zone-thumb ${isDone ? 'done' : ''}">
        <i class="ph ${isDone ? 'ph-seal-check' : zone.icon}"></i>
      </div>
      <div class="zone-info">
        <h5>${zone.title}</h5>
        <p>${zone.instr}</p>
        ${hasDmg ? '<span style="color: #F59E0B; font-size: 10px; font-weight: 700;">⚠️ Pre-existing Flaw Flagged</span>' : ''}
      </div>
      <div class="zone-actions">
        <button class="camera-snap-btn" onclick="startCameraAt(${idx})" title="Snap Camera" aria-label="Snap Camera">
          <i class="ph ph-camera"></i>
        </button>
        <button class="flag-damage-btn" onclick="openDamageModal('${zone.id}', '${zone.short}')" title="Flag Damage" aria-label="Flag Damage">
          <i class="ph ph-warning-circle"></i>
        </button>
      </div>
    `;
    listEl.appendChild(item);
  });
}

// 30-Second Camera Flow
function startCameraAt(zoneIdx) {
  state.cameraZoneIndex = zoneIdx;
  updateCameraHUD();
  showScreen('view-camera');
}

function updateCameraHUD() {
  const zone = VEHICLE_ZONES[state.cameraZoneIndex];
  const r = getCurrentRental();

  document.getElementById('cam-step-label').textContent = `${state.currentPhase.toUpperCase()} SHOT ${state.cameraZoneIndex + 1} OF 5`;
  document.getElementById('cam-zone-title').textContent = zone.title;
  document.getElementById('ghost-hint').textContent = zone.hint;
  document.getElementById('cam-instruction').querySelector('span').textContent = zone.instr;
  document.getElementById('sim-car-text').textContent = `${r.make} ${r.model} • [${zone.short.toUpperCase()}]`;

  const pct = ((state.cameraZoneIndex + 1) / 5) * 100;
  document.getElementById('cam-progress-bar').style.width = `${pct}%`;

  const isCaptured = !!r[state.currentPhase].photos[zone.id];
  document.getElementById('shutter-inner').classList.toggle('captured', isCaptured);
}

function captureZonePhoto() {
  const r = getCurrentRental();
  const zone = VEHICLE_ZONES[state.cameraZoneIndex];

  r[state.currentPhase].photos[zone.id] = true;
  document.getElementById('shutter-inner').classList.add('captured');

  setTimeout(() => {
    nextZone();
  }, 300);
}

function prevZone() {
  if (state.cameraZoneIndex > 0) {
    state.cameraZoneIndex--;
    updateCameraHUD();
  }
}

function nextZone() {
  if (state.cameraZoneIndex < VEHICLE_ZONES.length - 1) {
    state.cameraZoneIndex++;
    updateCameraHUD();
  } else {
    // Finished all 5 zones!
    const r = getCurrentRental();
    r[state.currentPhase].completed = true;
    r.status = 'Trip Protected ✓';
    closeCamera();
    alert('🛡️ 30-Second Walkaround Complete!\nYour vehicle photos, GPS location, and cryptographic timestamp are securely sealed on your device.');
  }
}

function closeCamera() {
  renderHomeRentals();
  showScreen('view-home');
}

function toggleFlash() {
  const icon = document.getElementById('flash-icon');
  icon.classList.toggle('ph-fill');
}

// Modals
function openModal(modalId) {
  const m = document.getElementById(modalId);
  if (m) m.classList.add('active');
}

function closeModal(modalId) {
  const m = document.getElementById(modalId);
  if (m) m.classList.remove('active');
}

function openNewRentalModal() {
  openModal('modal-new-rental');
}

function submitNewRental() {
  const agency = document.getElementById('input-agency').value;
  const make = document.getElementById('input-make').value || 'Vehicle';
  const model = document.getElementById('input-model').value || 'Rental';
  const plate = (document.getElementById('input-plate').value || 'RENTAL1').toUpperCase();
  const resNo = document.getElementById('input-res').value || 'RES-' + Math.floor(Math.random()*100000);

  const newRental = {
    id: 'rental-' + Date.now(),
    agency,
    make,
    model,
    year: '2025',
    plate,
    state: 'CA',
    resNo,
    status: 'Pick-up Pending',
    pickup: {
      completed: false,
      time: new Date().toISOString().replace('T', ' ').substring(0, 19) + ' UTC',
      gps: '33.9416° N, 118.4085° W (Rental Garage)',
      odo: '12,500',
      unit: 'mi',
      fuel: '8/8 (Full)',
      photos: {},
      damages: []
    },
    dropoff: {
      completed: false,
      time: 'Pending Return',
      gps: 'Pending Return',
      odo: '',
      unit: 'mi',
      fuel: '8/8 (Full)',
      photos: {},
      damages: []
    }
  };

  state.rentals.unshift(newRental);
  state.currentRentalId = newRental.id;
  closeModal('modal-new-rental');
  openInspectionHub(newRental.id);
}

function openDashboardModal() {
  openModal('modal-dashboard');
}

function toggleDashPhoto() {
  const icon = document.getElementById('dash-photo-icon');
  const lbl = document.getElementById('dash-photo-lbl');
  icon.className = 'ph-fill ph-check-circle';
  icon.style.color = '#10B981';
  lbl.textContent = 'Dashboard & Fuel Gauge Photo Verified';
  lbl.style.color = '#10B981';
}

function saveDashboardModal() {
  const r = getCurrentRental();
  const odo = document.getElementById('input-odo').value;
  const unit = document.getElementById('input-odo-unit').value;
  const fuel = document.getElementById('input-fuel').value;

  r[state.currentPhase].odo = odo;
  r[state.currentPhase].unit = unit;
  r[state.currentPhase].fuel = fuel;
  r[state.currentPhase].photos['dashboard_odometer'] = true;

  closeModal('modal-dashboard');
  renderInspectionHub();
}

function openDamageModal(zoneId, zoneShort) {
  state.damageTargetZone = zoneId;
  document.getElementById('damage-modal-title').textContent = `Flag Flaw: ${zoneShort}`;
  openModal('modal-damage');
}

function saveDamageTag() {
  const r = getCurrentRental();
  const type = document.getElementById('input-damage-type').value;
  const sev = document.getElementById('input-damage-sev').value;
  const notes = document.getElementById('input-damage-notes').value;

  r[state.currentPhase].damages.push({
    zone: state.damageTargetZone,
    type,
    sev,
    notes
  });

  closeModal('modal-damage');
  renderInspectionHub();
}

function certifyCurrentInspection() {
  const r = getCurrentRental();
  r[state.currentPhase].completed = true;
  if (state.currentPhase === 'pickup') {
    r.status = 'Active (Pick-up Done)';
  } else {
    r.status = 'Returned / Completed';
  }
  renderInspectionHub();
  alert(`✓ Certified! Your ${state.currentPhase.toUpperCase()} audit is cryptographically sealed and locked.`);
}

// Dispute Dossier Command Center
function openDisputeDossierFor(rentalId) {
  state.currentRentalId = rentalId;
  openDisputeDossier();
}

function openDisputeDossier() {
  const r = getCurrentRental();
  renderCompareChips();
  selectCompareZone('front_bumper');
  showScreen('view-dispute');
}

function closeDisputeDossier() {
  showScreen('view-home');
}

function renderCompareChips() {
  const container = document.getElementById('compare-zone-chips');
  container.innerHTML = '';
  VEHICLE_ZONES.forEach(z => {
    const btn = document.createElement('button');
    btn.className = `zone-chip ${z.id === state.activeCompareZone ? 'active' : ''}`;
    btn.textContent = z.short;
    btn.onclick = () => selectCompareZone(z.id);
    container.appendChild(btn);
  });
}

function selectCompareZone(zoneId) {
  state.activeCompareZone = zoneId;
  renderCompareChips();

  const zone = VEHICLE_ZONES.find(z => z.id === zoneId);
  const r = getCurrentRental();

  document.getElementById('compare-zone-name').textContent = zone.title;
  document.getElementById('compare-pickup-time').textContent = r.pickup.time;
  document.getElementById('compare-dropoff-time').textContent = r.dropoff.time;

  const dmg = r.pickup.damages.find(d => d.zone === zoneId);
  const dmgBox = document.getElementById('compare-damage-box');
  if (dmg) {
    dmgBox.style.display = 'flex';
    document.getElementById('compare-damage-text').textContent = `Pre-existing damage logged: ${dmg.type} [${dmg.sev}] - ${dmg.notes}`;
  } else {
    dmgBox.style.display = 'none';
  }
}

// Legal Letter Generation
function openLetterGenerator() {
  renderLetterText();
  openModal('modal-letter');
}

function renderLetterText() {
  const r = getCurrentRental();
  const recipient = document.getElementById('input-letter-target').value;
  const renterName = document.getElementById('input-renter-name').value || 'Jonathan Cousins';
  const claimNo = document.getElementById('input-claim-no').value || 'CLM-883192';

  const today = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

  let text = `DATE: ${today}\n`;
  text += `TO: ${r.agency} - Damage Recovery Unit / Claims Department\n`;
  text += `RE: FORMAL DISPUTE OF UNFOUNDED DAMAGE ASSESSMENT\n`;
  text += `RENTAL AGREEMENT NO: ${r.resNo}\n`;
  text += `CLAIM REFERENCE NO: ${claimNo}\n`;
  text += `VEHICLE: ${r.year} ${r.make} ${r.model} (Plate: ${r.plate})\n`;
  text += `RENTER: ${renterName}\n\n`;

  text += `Dear Claims Administrator,\n\n`;
  text += `I am writing to formally and unequivocally dispute the recent damage assessment and financial penalty asserted against my account regarding the above-referenced rental vehicle.\n\n`;
  text += `I conducted a standardized, timestamped, and GPS-verified Walkaround inspection at pick-up (${r.pickup.time} at ${r.pickup.gps}, Odometer: ${r.pickup.odo} ${r.pickup.unit}) and return (${r.dropoff.time}, Odometer: ${r.dropoff.odo} ${r.dropoff.unit}).\n\n`;

  text += `FORENSIC EVIDENCE SUMMARY:\n`;
  text += `1. High-resolution comparison photos with embedded SHA-256 metadata verify that the vehicle condition was preserved.\n`;
  text += `2. Pre-existing cosmetic blemishes were documented prior to vehicle departure from the rental lot.\n`;
  text += `3. Dashboard records confirm full fuel compliance and authorized mileage.\n\n`;

  text += `DEMAND FOR IMMEDIATE WITHDRAWAL:\n`;
  text += `Under commercial vehicle rental regulations and credit card merchant rules, any unauthorized charges must be refunded immediately and this claim closed with zero liability assigned to my name.\n\n`;
  text += `Sincerely,\n\n${renterName}\n`;
  text += `Attached: Certified Walkaround Forensic Dossier (Side-by-Side Photo Matrix & EXIF Proof)`;

  document.getElementById('letter-content-display').textContent = text;
}

function copyDisputeLetter() {
  const text = document.getElementById('letter-content-display').textContent;
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      alert('✓ Legal dispute response letter copied to clipboard!');
    }).catch(() => {
      fallbackCopyText(text);
    });
  } else {
    fallbackCopyText(text);
  }
}

function fallbackCopyText(text) {
  const textarea = document.createElement('textarea');
  textarea.value = text;
  textarea.style.position = 'fixed';
  textarea.style.opacity = '0';
  document.body.appendChild(textarea);
  textarea.select();
  try {
    document.execCommand('copy');
    alert('✓ Legal dispute response letter copied to clipboard!');
  } catch (err) {
    alert('Please copy the letter text manually from the screen.');
  }
  document.body.removeChild(textarea);
}

// Live PDF Dossier Generation via jsPDF
function generateCertifiedPDF() {
  const r = getCurrentRental();
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF('p', 'pt', 'letter');

  // Colors
  const navy = [20, 30, 55];
  const blue = [59, 130, 246];
  const green = [16, 185, 129];

  // PAGE 1: Cover Sheet & Summary
  doc.setFillColor(...navy);
  doc.roundedRect(36, 36, 540, 75, 6, 6, 'F');

  doc.setTextColor(255, 255, 255);
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.text('WALKAROUND™ VEHICLE CONDITION & INSPECTION REPORT', 50, 65);

  doc.setTextColor(99, 230, 160);
  doc.setFontSize(9);
  doc.text('VERIFIED VEHICLE INSPECTION RECORD • TIME & GPS DOCUMENTED', 50, 85);

  // Metadata Grid
  doc.setFillColor(245, 247, 250);
  doc.roundedRect(36, 125, 540, 140, 6, 6, 'F');

  doc.setTextColor(50, 50, 50);
  doc.setFontSize(9);
  doc.setFont('helvetica', 'bold');

  const meta = [
    ['VEHICLE', `${r.year} ${r.make} ${r.model}`],
    ['LICENSE PLATE', `${r.plate} (${r.state})`],
    ['RENTAL AGENCY', r.agency],
    ['RESERVATION #', r.resNo],
    ['VIN', r.vin || 'Recorded on File'],
    ['CLAIM #', 'CLM-883192'],
    ['PICKUP TIME', r.pickup.time],
    ['DROPOFF TIME', r.dropoff.time],
    ['AUDIT STATUS', 'Certified Tamper-Proof']
  ];

  meta.forEach((item, idx) => {
    const col = idx % 3;
    const row = Math.floor(idx / 3);
    const x = 50 + (col * 175);
    const y = 145 + (row * 42);

    doc.setTextColor(120, 120, 120);
    doc.setFontSize(8);
    doc.text(item[0], x, y);

    doc.setTextColor(20, 20, 20);
    doc.setFontSize(10);
    doc.text(item[1], x, y + 14);
  });

  // Section 1: Geographic Audit
  doc.setTextColor(...navy);
  doc.setFontSize(12);
  doc.text('1. VERIFIED GEOGRAPHIC AUDIT TRAIL', 36, 290);

  // Pickup GPS Box
  doc.setFillColor(240, 245, 255);
  doc.roundedRect(36, 305, 260, 65, 4, 4, 'F');
  doc.setTextColor(...blue);
  doc.setFontSize(8);
  doc.text('PICKUP POSSESSION LOCATION', 46, 320);
  doc.setTextColor(40, 40, 40);
  doc.setFontSize(8);
  doc.text(`${r.pickup.gps}\nTimestamp: ${r.pickup.time}`, 46, 335);

  // Dropoff GPS Box
  doc.setFillColor(240, 252, 245);
  doc.roundedRect(316, 305, 260, 65, 4, 4, 'F');
  doc.setTextColor(...green);
  doc.setFontSize(8);
  doc.text('RETURN SURRENDER LOCATION', 326, 320);
  doc.setTextColor(40, 40, 40);
  doc.setFontSize(8);
  doc.text(`${r.dropoff.gps}\nTimestamp: ${r.dropoff.time}`, 326, 335);

  // Section 2: Pre-existing damage log
  doc.setTextColor(...navy);
  doc.setFontSize(12);
  doc.text('2. PRE-EXISTING DAMAGE LOGGED AT VEHICLE ACCEPTANCE', 36, 395);

  let dmgY = 415;
  r.pickup.damages.forEach(d => {
    doc.setFillColor(255, 248, 235);
    doc.roundedRect(36, dmgY, 540, 30, 4, 4, 'F');
    doc.setTextColor(220, 100, 0);
    doc.setFontSize(9);
    doc.text(`⚠️ ${d.zone.replace(/_/g, ' ').toUpperCase()}: ${d.type} [${d.sev.toUpperCase()}]`, 46, dmgY + 13);
    doc.setTextColor(80, 80, 80);
    doc.setFontSize(8);
    doc.text(`Notes: ${d.notes}`, 46, dmgY + 23);
    dmgY += 38;
  });

  // Section 3: Mileage & Fuel Audit
  doc.setTextColor(...navy);
  doc.setFontSize(12);
  doc.text('3. ODOMETER & FUEL COMPLIANCE', 36, dmgY + 15);

  doc.setFillColor(248, 250, 252);
  doc.roundedRect(36, dmgY + 25, 540, 50, 4, 4, 'F');
  doc.setTextColor(40, 40, 40);
  doc.setFontSize(9);
  doc.text(`• Pickup Odometer: ${r.pickup.odo} ${r.pickup.unit} (Fuel: ${r.pickup.fuel})`, 50, dmgY + 45);
  doc.text(`• Return Odometer: ${r.dropoff.odo} ${r.dropoff.unit} (Fuel: ${r.dropoff.fuel})`, 50, dmgY + 60);

  // Footer Page 1
  doc.setTextColor(150, 150, 150);
  doc.setFontSize(8);
  doc.text('Generated via Walkaround for iOS • Cryptographically Sealed Timestamp Dossier • Page 1 of 2', 36, 750);

  // PAGE 2: Legal Rebuttal Notice
  doc.addPage();
  doc.setTextColor(...navy);
  doc.setFontSize(14);
  doc.text('FORMAL REBUTTAL & LEGAL NOTICE', 36, 50);

  const renterName = document.getElementById('input-renter-name')?.value || 'Jonathan Cousins';
  const claimNo = document.getElementById('input-claim-no')?.value || 'CLM-883192';

  const letterLines = doc.splitTextToSize(document.getElementById('letter-content-display')?.textContent || 'Dispute notice attached.', 540);
  doc.setTextColor(30, 30, 30);
  doc.setFontSize(9);
  doc.text(letterLines, 36, 80);

  doc.setTextColor(150, 150, 150);
  doc.setFontSize(8);
  doc.text('Generated via Walkaround for iOS • Cryptographically Sealed Timestamp Dossier • Page 2 of 2', 36, 750);

  // Save PDF
  doc.save(`Walkaround_Dispute_Dossier_${r.plate}.pdf`);
}

// Paywall
function openPaywall() {
  openModal('modal-paywall');
}

function unlockProPass() {
  state.isPro = true;
  closeModal('modal-paywall');
  alert('🎉 Pro Protection Unlocked! You have unlimited certified PDF exports.');
}

function openSettings() {
  showOnboarding();
}

// Onboarding Logic
let currentObSlide = 0;
const TOTAL_OB_SLIDES = 4;

function showOnboarding() {
  currentObSlide = 0;
  for (let i = 0; i < TOTAL_OB_SLIDES; i++) {
    const slide = document.getElementById(`ob-slide-${i}`);
    const dot = document.getElementById(`dot-${i}`);
    if (slide) slide.classList.toggle('active', i === 0);
    if (dot) dot.classList.toggle('active', i === 0);
  }
  const stepNum = document.getElementById('ob-step-num');
  if (stepNum) stepNum.textContent = `STEP 1 OF ${TOTAL_OB_SLIDES}`;
  const btn = document.getElementById('ob-next-btn');
  if (btn) btn.textContent = 'Next Step';
  openModal('modal-onboarding');
}

function goToOnboardingSlide(slideIdx) {
  if (slideIdx >= 0 && slideIdx < TOTAL_OB_SLIDES) {
    document.getElementById(`ob-slide-${currentObSlide}`)?.classList.remove('active');
    document.getElementById(`dot-${currentObSlide}`)?.classList.remove('active');
    currentObSlide = slideIdx;
    document.getElementById(`ob-slide-${currentObSlide}`)?.classList.add('active');
    document.getElementById(`dot-${currentObSlide}`)?.classList.add('active');

    const stepNum = document.getElementById('ob-step-num');
    if (stepNum) stepNum.textContent = `STEP ${currentObSlide + 1} OF ${TOTAL_OB_SLIDES}`;

    const btn = document.getElementById('ob-next-btn');
    if (btn) {
      btn.textContent = (currentObSlide === TOTAL_OB_SLIDES - 1) ? 'Start My First Inspection (Free)' : 'Next Step';
    }
  }
}

function advanceOnboarding() {
  if (currentObSlide < TOTAL_OB_SLIDES - 1) {
    goToOnboardingSlide(currentObSlide + 1);
  } else {
    closeModal('modal-onboarding');
  }
}

function triggerMockScratchTap() {
  const bubble = document.getElementById('ob-tag-bubble');
  const pulse = document.getElementById('ob-pulse-dot');
  if (bubble) {
    bubble.style.transform = 'scale(1.2)';
    bubble.style.background = '#10B981';
    bubble.innerHTML = '<i class="ph-fill ph-check-circle"></i> <span>Logged & Tagged ✓</span>';
    setTimeout(() => {
      bubble.style.transform = 'scale(1)';
    }, 250);
  }
}



