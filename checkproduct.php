<?php 
  session_start();
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Pharma</title>
    <link rel="ICON" href="images/icon.png" type="image/ico" />
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css">
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/mdbmin.css" rel="stylesheet">
    <link href="css/mdb.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">

  </head>
  <?php
  if(isset($_SESSION['role'])){
  ?>
  <body class="violetgradient">
    <?php
    include "navbar.php"
    ?>
    <center>
      <div class="customalert">
          <div class="alertcontent">
              <div id="alertText"> &nbsp </div>
              <img id="qrious">
              <div id="bottomText" style="margin-top: 10px; margin-bottom: 15px;"> &nbsp </div>
              <button id="closebutton" class="formbtn"> OK </button>
          </div>
      </div>
    </center>
    <div>
      <center>
        <div class="centered">
          <form role="form" autocomplete="off">
              <input type="text" id="searchText" class="searchBox" placeholder="Entrez le code produit" onkeypress="isInputNumber(event)" required>
              <label class=qrcode-text-btn style="width:4%;display:none;">
				<input type=file accept="image/*" id="selectedFile" style="display:none" capture=environment onchange="openQRCamera(this);" tabindex=-1>
			  </label>
			  <button type="submit" id="searchButton" class="searchBtn"><i class="fa fa-search"></i></button>
          </form>
			
		<button class="qrbutton" onclick="document.getElementById('selectedFile').click();">
		<i class='fa fa-qrcode'></i> Scannez le code QR
		</button>
	
          <br><br>
          <p id="database" class="cardstyle">
            Aucune donnée à afficher
          </p>
        </div>
      </center>
    </div>

    <div class='box'>
      <div class='wave -one'></div>
      <div class='wave -two'></div>
      <div class='wave -three'></div>
    </div>
  

  <?php }else{
    include 'redirection.php';
    redirect("index.php");
  } ?>
    <!-- JQuery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>

    <script src="js/popper.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/mdb.min.js"></script>


    <script src="web3.min.js"></script>
    <script src="app.js"></script>

	<!-- QR Code Reader -->
	<script src="https://rawgit.com/sitepoint-editors/jsqrcode/master/src/qr_packed.js"></script>
  
  </body>
</html>