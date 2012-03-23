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
  <portlet:param name="jspPage" value="/html/llamadastelefonicas/view.jsp" />
</portlet:resourceURL>

<script type="text/javascript" src="http://www.google.com/jsapi"></script>
<script type="text/javascript" src="/osinergmin-theme/js/portal/include.js"></script>

<link href='/osinergmin-theme/css/portlet-osinergmin.css' type=text/css rel=stylesheet>

<script type="text/javascript">
  /* Variables Globales - Google Maps */
  google.load('visualization', '1',{'packages':['corechart', 'table', 'geomap']});
  var key = 'AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4';
  
  jQuery(document).ready(function(){
      <portlet:namespace/>loadScript();
  });
  
  function <portlet:namespace/>loadScript() {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "http://maps.googleapis.com/maps/api/js?key=" + key + "&sensor=false&callback=<portlet:namespace/>initialize";
      document.body.appendChild(script);
  }
  
  function <portlet:namespace/>initialize() {
      var myLatlng = new google.maps.LatLng('-12.491991', '-76.72588');
      var myOptions = {
          zoom: 6,
          center: myLatlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
      }
      map = new google.maps.Map(document.getElementById("<portlet:namespace/>map"), myOptions);
        
      /*var marker = new google.maps.Marker({
          position: myLatlng, 
          map: map,
          title:"MiMarcador"
      });*/
  }
</script>

<div id="lb_errorbusqueda" >
  <div class="error_up"></div>
    <div class="error_center" style="width: 330px">
      <div class="error_mark">
        <div class="error_mark_img">
          <img src="/osinergmin-theme/images/maps/lb_error-mark.jpg" alt="" />
        </div>
        <div class="error_mark_cerrar">
          <p><a  onclick="lighBox.close('errorbusqueda');"><img src="/osinergmin-theme/images/maps/lb_error_cerrar.jpg" width="16" height="15" alt=""/></a></p>
        </div>
    </div>
    <div class="error_cont"  id="<portlet:namespace />cuerpomsjerror">
    </div>
  </div>
  <div class="error_bottom"></div>
</div>

 <div id="box_top">
 </div>
 <div id="box_map">
  <table style="width:740px;margin:0 auto;border:0">
    <tbody>
      <tr id="cm_mapTR">
        <td> <div id="<portlet:namespace/>map" style="overflow: hidden; width:740px; height:502px"><br><br>Cargando el Mapa - favor de ser paciente <br><br><br><img src=/osinergmin-theme/images/maps/ajax-loading.gif> </div> </td>
     </tr>
    </tbody>
  </table>
 </div>
 <div id="box_result">
   <div id="box_result_top">
     <h2 style="width:330px;margin-top:2px;text-align:center">Cuadro de B&uacute;squeda</h2>
   </div>
   <div id="box_result_middle">
     <table width="100%" border="0">
       <tr>
         <td><strong>&nbsp;&nbsp;Semestre</strong></td>
         <td>
           <select name="semestre" id="<portlet:namespace/>semestre" style="width:190px;margin-left:20px;">
             <option value=""></option>
           </select>
         </td>
       </tr>
       <tr>
         <td><strong>&nbsp;&nbsp;Empresa</strong></td>
         <td>
           <select name="empresa" id="<portlet:namespace/>empresa" style="width: 190px;margin-left:20px;">
             <option value=""></option>
           </select>                    
         </td>
       </tr>
       <tr>
         <td valign="bottom" style="align:baseline; margin-right:12px; float:right">
           <input type="button" id="<portlet:namespace/>buscar" value="Buscar" name="buscar" class="medium button grey">
         </td>
       </tr>
     </table>
   </div>
   <div id="box_result_bottom">
   </div>
 </div>