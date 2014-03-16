<!DOCTYPE html> 
<html>
	<head>
		<title>Kitty Gallery</title>
		<!--<meta http-equiv="Content-Type" content="text/html; charset=utf-8">-->
		<link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.0/jquery.mobile-1.4.0.min.css" />
		<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
		<script src="http://code.jquery.com/mobile/1.4.0/jquery.mobile-1.4.0.min.js"></script>
	</head>
	<body>
		<div data-role="page">
			<div data-role="header">
				<h1>Kitty Gallery</h1>
			</div>
			<div data-role="content" class="photolist">
				<ul id="allitems" data-role="listview" data-inset="true">
				</ul>
			</div>
		</div>
		<div data-role="page" id="detailPage" data-add-back-btn="true">
			<div data-role="header">
				<a href="#" data-rel="back">Back</a><h1 id="detailTitle"></h1>
			</div>
			<div data-role="content" id="detailContent" class="photoViewer">
				<img src="Transparent.gif" alt="Kitty photos will be loaded here" id="detailImage">
			</div>
		</div>
	<script type="text/javascript">
			var MOBILE = navigator.userAgent.match(/Android|Blackberry|iPhone|iPad|iPod|IEMobile/i);
			
			if(MOBILE){
				document.write("<link rel=stylesheet href='stylemobile.css'>");
			} else {
				document.write("<link rel=stylesheet href='styledesktop.css'>");
			}
			
			function addItemMobile(itemID, caption){
				var anchor = $("<a/>").text(caption).attr('href', '#detailPage').click(function(){
					$("#detailTitle").text(caption);
					$("#detailImage").attr('src', '');
					$("#detailImage").attr('src', 'viewimage.jsp?item='+itemID);
				});
				var li = $("<li/>").append(anchor);
				$("#allitems").append(li);
			}
			
			function addItemDesktop(itemID, caption){
				var loc = $("#allitems");
				loc.append($("<li />").append($("<h2 />").text(caption), $("<img />").attr('src', 'viewimage.jsp?item='+itemID)));
			}
			
			var addItem = MOBILE ? addItemMobile : addItemDesktop; 
			
			$.ajax({
				type: "GET",
				dataType: "json",
				url: "viewapi.jsp",
				success: function(items){
					for(var i=0; i < items.length; i++){
						var item = items[i];
						addItem(item.id, item.caption);
					} 
					try {
						$('#allitems').listview('refresh');
					} catch(e){
						$('#allitems').listview();
					}
				}, 
				error: function(a,b,c){
					alert("ERROR: "+a);
				}
			});
	</script>
	</body>
</html>