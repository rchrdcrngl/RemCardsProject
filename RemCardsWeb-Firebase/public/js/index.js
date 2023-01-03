
(function ($) {
  "use strict";


  /*==================================================================
  [ Validate ]*/
  var input = $('.validate-input .input100');

  $('.validate-form').on('submit', function () {
    var check = true;

    for (var i = 0; i < input.length; i++) {
      if (validate(input[i]) == false) {
        showValidate(input[i]);
        check = false;
      }
    }

    return check;
  });


  $('.validate-form .input100').each(function () {
    $(this).focus(function () {
      hideValidate(this);
    });
  });

  function validate(input) {
    if ($(input).attr('type') == 'email' || $(input).attr('name') == 'email') {
      if ($(input).val().trim().match(/^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{1,5}|[0-9]{1,3})(\]?)$/) == null) {
        return false;
      }
    }
    else {
      if ($(input).val().trim() == '') {
        return false;
      }
    }
  }

  function showValidate(input) {
    var thisAlert = $(input).parent();

    $(thisAlert).addClass('alert-validate');
  }

  function hideValidate(input) {
    var thisAlert = $(input).parent();

    $(thisAlert).removeClass('alert-validate');
  }



})(jQuery);



function login() {
  var userEmail = document.getElementById("email").value;
  var userPassword = document.getElementById("pass").value;
}

firebase.auth().onAuthStateChanged(function (user) {
  var userEmail = document.getElementById("email").value;
  var userPassword = document.getElementById("pass").value;
  if (user) {
    // User is signed in.
    window.location.replace("home.html");
  } else {

  }
});



function passReset() {
  var auth = firebase.auth();
  var userEmail = document.getElementById("email").value;

  auth.sendPasswordResetEmail(userEmail).then(function () {
    window.alert("Successful Password Reset! Check your email to confirm.");
  }).catch(function (error) {
    window.alert("Error Resetting Password!");
  });
}

function downloadAndroid() {
  var storage = firebase.storage().ref();
  var apk = storage.child('APKs/RemCards2_0.apk');
  apk.getDownloadURL()
    .then((url) => {
      var link = document.createElement("a");
      if (link.download !== undefined) {
        link.setAttribute("href", url);
        link.setAttribute("target", "_blank");
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    })
    .catch((error) => {
      // A full list of error codes is available at
      // https://firebase.google.com/docs/storage/web/handle-errors
      switch (error.code) {
        case 'storage/object-not-found':
          // File doesn't exist
          break;
        case 'storage/unauthorized':
          // User doesn't have permission to access the object
          break;
        case 'storage/canceled':
          // User canceled the upload
          break;

        // ...

        case 'storage/unknown':
          // Unknown error occurred, inspect the server response
          break;
      }
    });
}

function SignUp() {
  firebase.auth().createUserWithEmailAndPassword(email, password)
    .then((user) => {
      // Signed in 
      // ...
      window.alert("Sign Up Successful! Check your email to confirm account.");
    })
    .catch((error) => {
      var errorCode = error.code;
      var errorMessage = error.message;

      window.alert("Error Signing Up");
      // ..
    });
}