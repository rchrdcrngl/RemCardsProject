$(function() {

	'use strict';
  
	$('.js-menu-toggle').click(function(e) {
  
		var $this = $(this);
  
		
  
		if ( $('body').hasClass('show-sidebar') ) {
			$('body').removeClass('show-sidebar');
			$this.removeClass('active');
		} else {
			$('body').addClass('show-sidebar');	
			$this.addClass('active');
		}
  
		e.preventDefault();
  
	});
  
	// click outisde offcanvas
	  $(document).mouseup(function(e) {
	  var container = $(".sidebar");
	  if (!container.is(e.target) && container.has(e.target).length === 0) {
		if ( $('body').hasClass('show-sidebar') ) {
				  $('body').removeClass('show-sidebar');
				  $('body').find('.js-menu-toggle').removeClass('active');
			  }
	  }
	  }); 
  
	  
  
  });
  
  var currYear = (new Date()).getFullYear();
  
  $(document).ready(function() {
	$(".datepicker").datepicker({
	  format: "m/d/yyyy"    
	});
  });
  $(document).ready(function(){
	$('select').formSelect();
  });
  
  $(document).ready(function(){
	$('.sidenav').sidenav();
  });
	  
	  
  
  let db = firebase.database();


  firebase.auth().onAuthStateChanged(function(user) {
	if (user) {
	  // User is signed in.
	} else {
		window.location.replace("index.html");
	}
  });
  

  var today = new Date();
  var dd = today.getDate();
  var mm = today.getMonth()+1; 
  var yyyy = today.getFullYear();
  var date_today = mm + "/" + dd + "/" + yyyy;
  
  
  firebase.auth().onAuthStateChanged(function(user) {
	  if (user) {
		  var user = firebase.auth().currentUser;
		  var uid;
		  if (user != null) {
			uid = user.uid; 
  
  
			// READ
		  let list = document.getElementById("card-list");
		  let listRef = db.ref("/Data/" + uid).orderByChild("/tskdate").equalTo(date_today);
  
		  listRef.on("child_added", data => {
		  let cardID = data.key;
		  let subjCode = data.val().subjcode;
		  let tskDesc = data.val().tskdesc;
		  let tskDate = data.val().tskdate;
		  let tskLvl = data.val().tsklvl;
		  let tskStat = data.val().tskstat;
  
		  let div = document.createElement("div");
		  div.id = cardID;
		  div.setAttribute("class", "column");
		  div.innerHTML = card(cardID, subjCode, tskDesc, tskDate, tskLvl, tskStat);
		  list.appendChild(div);
		  });
  
		  list.addEventListener("click", e => {
			  let listNode = e.target.parentNode.parentNode;
			  if (e.target.id == "updatestat") {
				var cid = listNode.querySelector("#cardID").innerText;
				var sc = listNode.querySelector("#subjCode").innerText;
				var tdc = listNode.querySelector("#tskDesc").innerText;
				var tdt = listNode.querySelector("#tskDate").innerText;
				var tlv = listNode.querySelector("#tskLvl").innerText;
				var tst = listNode.querySelector("#tskStat").innerText;
				var stat;
				var lvl;
				if (tst == "Idle"){
				  stat = 1;
				} else if (tst == "Started") {
				  stat = 2;
				} else if (tst == "Ongoing") {
				  stat = 3;
				} else if (tst == "Urgent") {
				  stat = 4;
				} else if (tst == "Finished") {
				  stat = 0;
				} else {
				  stat = 0;
				}

				if (tlv == "Low Priority"){
					lvl = 1;
				  } else if (tlv == "Mid Priority") {
					lvl = 2;
				  } else if (tlv == "High Priority") {
					lvl = 3;
				  } else {
					lvl = 1;
				}  


				updateCard(uid, cid, sc, tdc, tdt, lvl, stat);
				
				
			  }
			});
  
  
			  listRef.on("child_changed", data => {
			  let cardID = data.key;
			  let subjCode = data.val().subjcode;
			  let tskDesc = data.val().tskdesc;
			  let tskDate = data.val().tskdate;
			  let tskLvl = data.val().tsklvl;
			  let tskStat = data.val().tskstat;
  
			  let listNode = document.getElementById(cardID);
			  listNode.innerHTML = card(cardID, subjCode, tskDesc, tskDate, tskLvl, tskStat);
			  });
  
			  listRef.on("child_removed", data => {
			  let listNode = document.getElementById(data.key);
			  listNode.parentNode.removeChild(listNode);
			  });
		  }
	  } else {
		// No user is signed in.
	  }
	});
  
	
  function updateCard(uid, cid, sc, tdc, tdt, tlv, stat){
	var postData = {
	  subjcode: sc,
	  tskdesc: tdc,
	  tskdate: tdt,
	  tsklvl: tlv,
	  tskstat: stat,
	};
  
	
	var updates = {};
	updates['/Data/' + uid + '/' + cid] = postData;
  
	return firebase.database().ref().update(updates);
  }
  
  function card(cardID, subjCode, tskDesc, tskDate, tskLvl, tskStat) {
	var status, lvl, bg;
	if (tskStat == 0){
	  status = "Idle";
	} else if (tskStat == 1) {
	  status = "Started";
	} else if (tskStat == 2) {
	  status = "Ongoing";
	} else if (tskStat == 3) {
	  status = "Urgent";
	} else if (tskStat == 4) {
	  status = "Finished";
	} else {
	  status = "Idle";
	}
  
	if (tskLvl == 1){
	  lvl = "Low Priority";
	  bg = "blue";
	} else if (tskLvl == 2) {
	  lvl = "Mid Priority";
	  bg = "yellow";
	} else if (tskLvl == 3) {
	  lvl = "High Priority";
	  bg = "red";
	} else {
	  lvl = "Low Priority";
	  bg = "blue";
	}  
  
	return `
	<div class="remcard ${bg}">
		  <div class="card-content">
			  <span class="card-title" id="tskDesc">${tskDesc}</span>
				<p id="subjCode" class="w300 white-text">${subjCode}</p>
				<p id="tskDate" class="w200 white-text">${tskDate}</p>
				<p id="tskLvl" class="w100 white-text">${lvl}</p>
				<p hidden id="tskStat">${status}</p>
				<p hidden id="cardID">${cardID}</p>
		  </div>
		<div class="card-action">
		  <a id="updatestat" class="white-text">${status}</a>
		  <a id="edit" class="fa fa-edit modal-trigger white-text" href="#card-edit" onclick="openEdit()"></a>
		  <a id="delcard" class="fa fa-trash white-text" onclick="deleteCard()"></a>
		  <a hidden class="w100 right white-text">${cardID}</a>
	  	</div>
	  
	</div>
	<br>
	`;
  }
  
  
  function signout(){
	  firebase.auth().signOut().then(function() {
		  window.location.replace("index.html");
		}).catch(function(error) {
		  window.alert("An error has occured. Try Again.");
		});
	  
  }
  
  function addCard(){
	firebase.auth().onAuthStateChanged(function(user) {
	  if (user) {
		  var user = firebase.auth().currentUser;
		  var uid;
		  if (user != null) {
			uid = user.uid; 
		  }
  
		  var newPostKey = firebase.database().ref("Data").child(uid).push().key;
  
		 
		  
		  var subjCode = document.getElementById("frm-subjcode").value;
		  var tskDesc = document.getElementById("frm-tskdesc").value;
		  var tskDate = document.getElementById("frm-tskdate").value;
		  var tskLvl = parseInt(document.getElementById("frm-tsklvl").value);
		  var tskStat = parseInt(document.getElementById("frm-tskstat").value);
  
		  db.ref("/Data/" + uid + "/" + newPostKey).set({
			subjcode: subjCode,
			tskdesc: tskDesc,
			tskdate: tskDate,
			tsklvl: tskLvl,
			tskstat: tskStat
		  });
  
  
	  } else {
		window.alert("ERROR: TRY AGAIN");
	  }
	});
  }
  
  function editCard(){
	firebase.auth().onAuthStateChanged(function(user) {
	  if (user) {
		  var user = firebase.auth().currentUser;
		  var uid;
		  if (user != null) {
			uid = user.uid; 
		  }
  
		  let list = document.getElementById("card-list");
		  let listRef = db.ref("/Data/" + uid);
  
		 
		  var cardID = document.getElementById("edit-cardid").value;
		  var subjCode = document.getElementById("edit-subjcode").value;
		  var tskDesc = document.getElementById("edit-tskdesc").value;
		  var tskDate = document.getElementById("edit-tskdate").value;
		  var tskLvl = parseInt(document.getElementById("edit-tsklvl").value);
		  var tskStat = parseInt(document.getElementById("edit-tskstat").value);

  
		  db.ref("/Data/" + uid + "/" + cardID).set({
			subjcode: subjCode,
			tskdesc: tskDesc,
			tskdate: tskDate,
			tsklvl: tskLvl,
			tskstat: tskStat
		  });
  
  
		} else {
		  window.alert("ERROR: TRY AGAIN");
		}
	});
  }
  
  function openEdit(){
	firebase.auth().onAuthStateChanged(function(user) {
	  if (user) {
		var user = firebase.auth().currentUser;
		var uid;
		if (user != null) {
		  uid = user.uid; 
		}
  
		let list = document.getElementById("card-list");
		let listRef = db.ref("/Data/" + uid);
  
		list.addEventListener("click", e => {
		  let listNode = e.target.parentNode.parentNode.parentNode;
		  
	  
		  // UPDATE
		  if (e.target.id == "edit") {
			
			document.getElementById("edit-cardid").value = listNode.querySelector("#cardID").innerText;
			document.getElementById("edit-subjcode").value = listNode.querySelector("#subjCode").innerText;
			document.getElementById("edit-tskdesc").value = listNode.querySelector("#tskDesc").innerText;
			document.getElementById("edit-tskdate").value = listNode.querySelector("#tskDate").innerText;
			var lvl = listNode.querySelector("#tskLvl").innerText;
			var tst = listNode.querySelector("#tskStat").innerText;
			var stat, level;
			if (tst == "Idle"){
			  stat = 0;
			} else if (tst == "Started") {
			  stat = 1;
			} else if (tst == "Ongoing") {
			  stat = 2;
			} else if (tst == "Urgent") {
			  stat = 3;
			} else if (tst == "Finished") {
			  stat = 4;
			} else {
			  stat = 0;
			}
			if (lvl == "Low Priority") {
			  level = 1;
			} else if (lvl == "Mid Priority"){
			  level = 2;
			} else if (lvl == "High Priority"){
			  level = 3;
			} else {
			  level = 1;
			}
			document.getElementById("edit-tskstat").value = stat;
			document.getElementById("edit-tsklvl").value = level;
  
		  }
		}
		);
	
  
	  } else {
	  window.alert("ERROR: TRY AGAIN");
	  }
	});
  }
  
  function deleteCard(){
	firebase.auth().onAuthStateChanged(function(user) {
	  if (user) {
		var user = firebase.auth().currentUser;
		var uid;
		if (user != null) {
		  uid = user.uid; 
		}
  
		let list = document.getElementById("card-list");
  
		list.addEventListener("click", e => {
		  let listNode = e.target.parentNode.parentNode.parentNode;
		  
	  
		  let id = listNode.querySelector("#cardID").innerText;
		  db.ref("/Data/" + uid + "/" + id).remove();
		  
		}
		);

		window.location.replace("home.html");
	
  
	  } else {
	  window.alert("ERROR: TRY AGAIN");
	  }
	});
  }
  