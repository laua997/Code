// 1. Config
const firebaseConfig = {
    apiKey: "AIzaSyAc3KNyiCxebl5E_oqbnj4S7fHPNOCAvP0",
    authDomain: "laua997-test.firebaseapp.com",
    databaseURL: "https://laua997-test-default-rtdb.firebaseio.com",
    projectId: "laua997-test",
    storageBucket: "laua997-test.firebasestorage.app",
    messagingSenderId: "34314755962",
    appId: "1:34314755962:web:e5f935d3321d399a1fc0c3"
};

// 2. Init
firebase.initializeApp(firebaseConfig);
const db = firebase.database();
const auth = firebase.auth();

// Variables
let currentUser = null;
let isSignupMode = false;
let debounceTimer;

// DOM Elements
const authModal = document.getElementById('authModal');
const datePicker = document.getElementById('datePicker');
const statusLabel = document.getElementById('status');
const authError = document.getElementById('authError');

// --- AUTH LOGIC ---

auth.onAuthStateChanged(user => {
    if (user) {
        currentUser = user;
        document.body.classList.remove('logged-out');
        document.getElementById('loggedOutUI').classList.add('hidden');
        document.getElementById('loggedInUI').classList.remove('hidden');
        document.getElementById('userEmail').innerText = user.email;
        authModal.classList.add('hidden');
        loadWeekData();
    } else {
        currentUser = null;
        document.body.classList.add('logged-out');
        document.getElementById('loggedOutUI').classList.remove('hidden');
        document.getElementById('loggedInUI').classList.add('hidden');
        statusLabel.innerText = "Logged Out";
    }
});

document.getElementById('openLogin').onclick = () => { isSignupMode = false; document.getElementById('modalTitle').innerText = "Login"; authModal.classList.remove('hidden'); };
document.getElementById('openSignup').onclick = () => { isSignupMode = true; document.getElementById('modalTitle').innerText = "Sign Up"; authModal.classList.remove('hidden'); };
document.getElementById('closeModal').onclick = () => authModal.classList.add('hidden');

document.getElementById('googleBtn').onclick = () => {
    const provider = new firebase.auth.GoogleAuthProvider();
    auth.signInWithPopup(provider).catch(e => authError.innerText = e.message);
};

document.getElementById('authSubmitBtn').onclick = () => {
    const email = document.getElementById('email').value;
    const pass = document.getElementById('password').value;
    if (isSignupMode) {
        auth.createUserWithEmailAndPassword(email, pass).catch(e => authError.innerText = e.message);
    } else {
        auth.signInWithEmailAndPassword(email, pass).catch(e => authError.innerText = e.message);
    }
};

document.getElementById('logoutBtn').onclick = () => auth.signOut();

// --- DATA LOGIC ---

function getMonday(d) {
    d = new Date(d);
    let day = d.getDay(), diff = d.getDate() - day + (day == 0 ? -6 : 1);
    return new Date(d.setDate(diff)).toISOString().split('T')[0];
}

datePicker.value = new Date().toISOString().split('T')[0];

function loadWeekData() {
    if (!currentUser) return;
    const weekId = getMonday(datePicker.value);
    statusLabel.innerText = "Loading...";
    db.ref(`users/${currentUser.uid}/weeks/${weekId}`).once('value', snap => {
        const data = snap.val() || {};
        document.querySelectorAll('[data-day]').forEach(ta => {
            ta.value = data[ta.getAttribute('data-day')] || "";
        });
        document.getElementById('generalNotes').value = data.generalNotes || "";
        statusLabel.innerText = "Saved";
    });
}

function saveData() {
    if (!currentUser) return;
    statusLabel.innerText = "Saving...";
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
        const weekId = getMonday(datePicker.value);
        const data = { generalNotes: document.getElementById('generalNotes').value };
        document.querySelectorAll('[data-day]').forEach(ta => {
            data[ta.getAttribute('data-day')] = ta.value;
        });
        db.ref(`users/${currentUser.uid}/weeks/${weekId}`).set(data)
            .then(() => statusLabel.innerText = "Saved");
    }, 800);
}

datePicker.onchange = loadWeekData;
document.querySelectorAll('textarea').forEach(t => t.oninput = saveData);