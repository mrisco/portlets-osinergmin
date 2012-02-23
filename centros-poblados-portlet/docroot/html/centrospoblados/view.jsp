<%--
/**
* Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
--%>

<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<portlet:defineObjects />
<portlet:resourceURL  var="urlResource"  >
  <portlet:param name="jspPage" value="/html/centrospoblados/view.jsp" />
</portlet:resourceURL>

<script type="text/javascript" src="/osinergmin-theme/js/portal/include.js"></script>

<script type="text/javascript">
  jQuery(document).ready(function(){
	  <portlet:namespace/>loadScript();
	  jQuery("<div>Hi There!</div>").insertAfter("#<portlet:namespace/>followMe");
	  jQuery("#<portlet:namespace/>consultar").click(function() {<portlet:namespace/>consultarDatos();});
  });
  
  function <portlet:namespace/>loadScript() {
	  var script = document.createElement("script");
	  script.type = "text/javascript";
	  script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4&sensor=false&callback=<portlet:namespace/>initialize";
	  document.body.appendChild(script);  
  }
  
  function <portlet:namespace/>initialize() {
	  var myLatlng = new google.maps.LatLng('-34.397', '150.644');
	  var myOptions = {
	      zoom: 8,
	      center: myLatlng,
	      mapTypeId: google.maps.MapTypeId.ROADMAP
	  }
	  var map = new google.maps.Map(document.getElementById("<portlet:namespace/>div_map_canvas"), myOptions);
	    
	  var marker = new google.maps.Marker({
	      position: myLatlng, 
	      map: map,
	      title:"MiMarcador"
	  });
  }
  
  function <portlet:namespace/>consultarDatos() {
	  jQuery.ajax({
          url: '<%=urlResource%>',
          type: 'post',
          dataType: 'json',
          data: { <portlet:namespace/>metodo: 'consultarGEO',  
                },
          success: function(val) {
        	  alert("XX " + val);
        	  if (val.salida == 9) {
        		  jQuery("<div>Resultado Esperado!!!!</div>").insertAfter("#<portlet:namespace/>followMe");
        	  } else {
        		  jQuery("<div>Resultado Inesperado????</div>").insertAfter("#<portlet:namespace/>followMe");
        	  }     
          }
      });
	  jQuery("<div>Que se puede hacer???</div>").insertAfter("#<portlet:namespace/>followMe");
  }
</script>

This is the <b>CentrosPoblados XXX</b> portlet in View mode.
<div id="<portlet:namespace/>followMe">Follow me!</div>

<div class="map_google">
  <div id="<portlet:namespace/>div_map_canvas" style="width: 1200px; height: 500px;"></div>
</div>
<div class="main_form">
  <input type="button" id="<portlet:namespace/>consultar" value="Consultar" /> 
</div>
