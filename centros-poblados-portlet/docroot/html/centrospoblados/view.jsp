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

<script type="text/javascript" src="http://www.google.com/jsapi"></script>
<script type="text/javascript" src="/osinergmin-theme/js/portal/include.js"></script>

<link href='/osinergmin-theme/css/portlet-osinergmin.css' type=text/css rel=stylesheet>

<script type="text/javascript">
  /* Variables Globales - Google Maps */
  google.load('visualization', '1',{'packages':['corechart', 'table', 'geomap']});
  var map, layer_localidad, layer_sed;
  var key = 'AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4';
  var ft_localidad = '11l7q3ruvlJ3hI24hjgSSUgGhVLw1uNyC8UIDllY';
  var ft_sed = '1GXSR3vGYMEazmQlL-nqN4pKyNPIgTfFpgd3GQrc';
  var ft_localidad_id = 3110406;
  var ft_sed_id = 3109998;
  var buscar = false;
  var vector_excel = new Array();
  var polygon, ncol_excel = 0, nrow_excel = 0;
  
  jQuery(document).ready(function(){
      <portlet:namespace/>loadScript();
      <portlet:namespace/>initCombos();
      jQuery("#<portlet:namespace/>semestre").change(function() {<portlet:namespace/>initComboSemestre();});
      jQuery("#<portlet:namespace/>empresa").change(function() {<portlet:namespace/>initComboEmpresa();});
      jQuery("#<portlet:namespace/>localidad").change(function() {buscar = false;});
      jQuery("#<portlet:namespace/>buscar").click(function() {<portlet:namespace/>buscarDatos();});
      jQuery("#<portlet:namespace/>chk_sed").click(function() {<portlet:namespace/>habilitarLayers();});
      jQuery("#<portlet:namespace/>export_xls").click(function() {<portlet:namespace/>exportarExcel();});
      jQuery("#<portlet:namespace/>list_localidad").change(function() {<portlet:namespace/>updateResultDetail();});
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
      
      layer_sed = new google.maps.FusionTablesLayer();
      layer_localidad = new google.maps.FusionTablesLayer();
      
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "/osinergmin-theme/js/portal/maps.google.polygon.containsLatLng.js";
      document.body.appendChild(script);
  }
  
  function <portlet:namespace/>initCombos() {
      var sql = 'SELECT semestre, nombre_semestre FROM ' + ft_localidad + ' ORDER BY semestre';
      ft2json.query(sql, <portlet:namespace/>fillCombos);
  }
  
  function <portlet:namespace/>initComboSemestre() {
      var semestre = jQuery('#<portlet:namespace/>semestre option:selected').val();
      var sql = 'SELECT empresa, nombre_empresa FROM ' + ft_localidad + ' WHERE semestre = ' + semestre + ' ORDER BY empresa';
      ft2json.query(sql, <portlet:namespace/>fillComboSemestre);
      buscar = false;
  }

  function <portlet:namespace/>initComboEmpresa() {
      var empresa = jQuery('#<portlet:namespace/>empresa option:selected').val();
      var semestre = jQuery('#<portlet:namespace/>semestre option:selected').val();
      var sql = 'SELECT localidad, nombre_localidad FROM ' + ft_localidad + ' WHERE empresa = \'' + empresa + '\' AND semestre = ' + semestre + ' ORDER BY localidad';
      ft2json.query(sql, <portlet:namespace/>fillComboEmpresa);
      buscar = false;
  }
  
  function <portlet:namespace/>fillCombos(result) {
      var html = '<option value="">- Seleccionar un Semestre -' + <portlet:namespace/>parseResultQuery(result, 'semestre', 'nombre_semestre');
      
      jQuery("#<portlet:namespace/>semestre").html(html);
      html = '<option value="">- Seleccionar una Empresa -</option>';
      jQuery("#<portlet:namespace/>empresa").html(html);
      html = '<option value="">- Seleccionar una Localidad -</option>';
      jQuery("#<portlet:namespace/>localidad").html(html);
  }

  function <portlet:namespace/>fillComboSemestre(result) {
      var html = '<option value="">- Seleccionar una Empresa -</option>' + <portlet:namespace/>parseResultQuery(result, 'empresa', 'nombre_empresa');
      
      jQuery("#<portlet:namespace/>empresa").html(html);
      html = '<option value="">- Seleccionar una Localidad -</option>';
      jQuery("#<portlet:namespace/>localidad").html(html);
  }
  
  function <portlet:namespace/>fillComboEmpresa(result) {
      var html = '<option value="">- Seleccionar una Localidad -</option>' + <portlet:namespace/>parseResultQuery(result, 'localidad', 'nombre_localidad');
      
      jQuery("#<portlet:namespace/>localidad").html(html);
  }
  
  /*
   * Funcion que devuelve el contenido HTML de un ComboBox, a partir del resultado de la query a una FusionTable, se asume que el resultado esta ordenado (SQL ORDER BY)
   * Parametros:
   *   result: Resultado del query al FusionTable
   *   id:     Nombre de la columna del valor del elemento del ComboBox
   *   nombre: Nombre de la columna del texto del elemento del ComboBox
   */
  function <portlet:namespace/>parseResultQuery(result, id, nombre) {
      var html = '';
      var val_id = '';
      var val_nombre = '';
      var aux_id = '', aux_nombre = '';
      
      for(i in result) {
          if(i == 'data') {
              for(var j = 0; j < result[i].length; j++) {
                  for(k in result[i][j]) {
                      if (k == id) { val_id = result[i][j][k]; }
                      if (k == nombre) { val_nombre = result[i][j][k]; }
                  }
                  if ((val_id != aux_id) || (val_nombre != aux_nombre)) {
                     html = html + '<option value="' + val_id + '">' + val_nombre + '</option>';
                  }
                  aux_id = val_id;
                  aux_nombre = val_nombre;
              }
          }
      }
      return html;
  }
  
  function <portlet:namespace/>habilitarLayers() {
      if (buscar) {
         <portlet:namespace/>filterMap("#<portlet:namespace/>localidad");
      }
  }
  
  function <portlet:namespace/>buscarDatos() {
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      
      if ((semestre == '') || (empresa == '')){
         var addhtml='<p class="error_warning">No se ha ingresado correctamente los datos</p>';
         addhtml+='<p class="error_msj">Debe seleccionar un valor para Semestre y un valor para Empresa</p>';
         jQuery("#<portlet:namespace />cuerpomsjerror").html(addhtml);
         lighBox.open('errorbusqueda');
      } else {
         buscar = true;
         <portlet:namespace/>filterMap("#<portlet:namespace/>localidad");
         <portlet:namespace/>updateResultHeader();
      }
  }
  
  function <portlet:namespace/>filterMap(localidad_element) {
      var chk_sed = jQuery("#<portlet:namespace/>chk_sed").is(':checked');
      var chk_set = jQuery("#<portlet:namespace/>chk_set").is(':checked');
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      //var localidad = jQuery("#<portlet:namespace/>localidad option:selected").val();
      var localidad = jQuery(localidad_element + " option:selected").val();
      
      var where = '';
      if (semestre != '') {
         where = where + 'semestre = \'' + semestre + '\'';
      }
      if (empresa != '') {
         where = where + ' and empresa = \'' + empresa + '\'';
      }
      if (localidad != '') {
         where = where + ' and localidad = \'' + localidad + '\'';
      }
  
      var option_localidad = {
            styles: [{
                polygonOptions: {
                    fillColor: "#00ff00",
                    strokeColor: "#fffff00", 
                    strokeWeight: 2,
                    strokeOpacity : 0.5
                }
            }],
            map:map,
            query: {
                select: 'geometry',
                from: ft_localidad_id,
                where: where
            }
          }
      
      var option_sed = {
         map: map,
         query: {
             select: 'geometry',
             from: ft_sed_id,
             where: where
         }
      }
      
      // Aplicamos el zoom de la busqueda
      var query_zoom = "SELECT geometry FROM " + ft_localidad_id + " WHERE " + where;
      <portlet:namespace/>zoom2query(query_zoom);
      
      layer_localidad.setOptions(option_localidad);
      if (chk_sed) {
         if ( !layer_sed.getMap() ) {
            layer_sed.setMap(map);
         }
         layer_sed.setOptions(option_sed);
      } else {
         layer_sed.setMap(null);
      }
  }
  
  function <portlet:namespace/>updateResultHeader() {
      var localidad = jQuery("#<portlet:namespace/>localidad option:selected").val();
      var html = '';
      var text = '';
      
      jQuery("#result-header").css({visibility: "visible"});
      jQuery("#result-detail").css({visibility: "hidden"});
      if (localidad == '') {
          html = jQuery("#<portlet:namespace/>localidad").html();
          jQuery("#<portlet:namespace/>list_localidad").html(html);
      } else {
          html = jQuery('#<portlet:namespace/>localidad option:selected').val();
          text = jQuery('#<portlet:namespace/>localidad option:selected').text();
          html = '<option value="' + html + '">' + text + '</option>';
          jQuery("#<portlet:namespace/>list_localidad").html(html);
          
          html = '<p>&nbsp;</p>';
          jQuery("#list_msg").html(html);
          <portlet:namespace/>generarDatos();
          jQuery("#result-detail").css({visibility: "visible"});
      }
  }
  
  function <portlet:namespace/>updateResultDetail() {
      var localidad = jQuery("#<portlet:namespace/>list_localidad option:selected").val();
      var html = '';
      
      if (localidad == '') {
         jQuery("#result-detail").css({visibility: "hidden"});
      } else {
         <portlet:namespace/>filterMap("#<portlet:namespace/>list_localidad");
         html = '<p>&nbsp;</p>';
         jQuery("#list_msg").html(html);
         <portlet:namespace/>generarDatos();
         jQuery("#result-detail").css({visibility: "visible"});
      }
  }
  
  function <portlet:namespace/>consultarDatos() {
      jQuery.ajax({
          url: '<%=urlResource%>',
          type: 'post',
          dataType: 'json',
          data: { <portlet:namespace/>metodo: 'json',  
                },
          success: function(val) {
              if (val.salida == 9) {
                  alert("Resultado Esperado!!!!");
              } else {
                  alert("Resultado Inesperado????");
              }     
          }
      });
  }
  
  /*
   * Funciones zoom2query y zoomTo, usadas para realizar el zoom al momento de la busqueda
   */
  function <portlet:namespace/>zoom2query(query) {
      var queryText = encodeURIComponent(query);
      var query = new google.visualization.Query('http://www.google.com/fusiontables/gvizdata?tq='  + queryText);
      
      //set the callback function
      query.send(<portlet:namespace/>zoomTo);
  }

  function <portlet:namespace/>zoomTo(response) {
      if (!response) {
          alert('no response');
          return;
      }
      if (response.isError()) {
          alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
          return;
      } 

      var numRows = response.getDataTable().getNumberOfRows();
      var numCols = response.getDataTable().getNumberOfColumns();
      var unionBounds = null;
      var kml;
   
      for(var i=0; i<numRows; i++) {
          kml =  response.getDataTable().getValue(i,0);
          var geoXml = new geoXML3.parser({
               map: map,
               zoom: false
          });
          geoXml.parseKmlString("<Placemark>"+kml+"</Placemark>");
          geoXml.docs[0].gpolygons[0].setMap(null);
          if (!unionBounds) unionBounds = geoXml.docs[0].gpolygons[0].bounds;
          else unionBounds.union(geoXml.docs[0].gpolygons[0].bounds);
      }      
      map.fitBounds(unionBounds);
  }
  
  function <portlet:namespace/>exportarExcel() {
        /* Llamada para al portlet para la generacion del archivo excel */
      var url='<portlet:resourceURL></portlet:resourceURL>';
      //jQuery.post(url, {arrayDatos:vector, ncol:ncol, nrow:nrow, metodo:"excel"});
      var frm = document.<portlet:namespace/>centrospoblados;
      frm.action=url+'&metodo=excel&arrayDatos='+vector_excel.join('|')+'&ncol='+ncol_excel+'&nrow='+nrow_excel;
      frm.submit();
  }
  
  function <portlet:namespace/>generarDatos() {
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      var localidad = jQuery("#<portlet:namespace/>list_localidad option:selected").val();
      
      var where = ' WHERE semestre = \'' + semestre + '\' and empresa = \'' + empresa + '\' and localidad = \'' + localidad + '\'';
      var sql_localidad = 'SELECT geometry, nombre_localidad, localidad FROM ' + ft_localidad + where;
      ft2json.query(sql_localidad, <portlet:namespace/>generarDatosArray);
  }
  
  function <portlet:namespace/>generarDatosArray(result) {
      var geometry = 'geometry', val_geometry = '', mvc_array = '', latlng = '', lat = '', lng = '';
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      var localidad = jQuery("#<portlet:namespace/>list_localidad option:selected").val();
      
      var where = ' WHERE semestre = \'' + semestre + '\' and empresa = \'' + empresa + '\' and localidad = \'' + localidad + '\'';
      var sql_sed = 'SELECT geometry, nombre_sed, sed, semestre, empresa, localidad FROM ' + ft_sed + where +' ORDER BY sed';
      
      for(i in result) {
          if(i == 'data') {
              for(var j = 0; j < result[i].length; j++) {
                  for(k in result[i][j]) {
                      if (k == geometry) { val_geometry = result[i][j][k]; }
                  }
                  latlng = val_geometry.split(',');
                  mvc_array = new google.maps.MVCArray();
                  for (k=0; k<latlng.length-1; k=k+2) {
                      if (k==0) { 
                         lng = latlng[k].replace('<Polygon><outerBoundaryIs><LinearRing><coordinates>','');
                      } else {
                         lng = latlng[k].split(' ')[1];
                      }
                      lat = latlng[k+1];
                      mvc_array.push(new google.maps.LatLng(lat,lng));
                  }
                  polygon = new google.maps.Polygon({path: mvc_array});
              }
          }
      }
      ft2json.query(sql_sed, <portlet:namespace/>spatialQuery);
  }
  
  function <portlet:namespace/>spatialQuery(result) {
      var sed = 'sed', nombre_sed = 'nombre_sed', semestre = 'semestre', empresa = 'empresa', localidad = 'localidad', geometry = 'geometry';
      var val_sed = '', val_nombre_sed = '', val_semestre = '', val_empresa = '', val_localidad = '', val_geometry = '';
      var ncol = 6, nrow = 0, index = 0, nrow_in = 0, nrow_out = 0;
      var vector = new Array();
      
      for(i in result) {
          if(i == 'data') {
              for(var j = 0; j < result[i].length; j++) {
                  for(k in result[i][j]) {
                      if (k == sed) { val_sed = result[i][j][k]; }
                      if (k == nombre_sed) { val_nombre_sed = result[i][j][k]; }
                      if (k == semestre) { val_semestre = result[i][j][k]; }
                      if (k == empresa) { val_empresa = result[i][j][k]; }
                      if (k == localidad) { val_localidad = result[i][j][k]; }
                      if (k == geometry) { val_geometry = result[i][j][k]; }
                  }
                  index = nrow*ncol;
                  vector[index+0] = val_sed;
                  vector[index+1] = val_nombre_sed;
                  vector[index+2] = val_semestre;
                  vector[index+3] = val_empresa;
                  vector[index+4] = val_localidad;
                  vector[index+5] = 'No';
                  nrow++;
                  
                  /* Consulta Espacial */
                  point = val_geometry.split(',',2);
                  lng = point[0].replace('<Point><coordinates>','');
                  lat = point[1];
                  coordinate = new google.maps.LatLng(lat,lng);
                  if (polygon.containsLatLng(coordinate)) { 
                      vector[index+5] = 'Si'; 
                      nrow_in++;
                  }
              }
          }
      }
      vector_excel = vector;
      nrow_excel = nrow; ncol_excel = ncol;
      //alert(vector.join('|')); return;
      
      nrow_out = nrow - nrow_in;
      var html = '<p>' + nrow + ' SEDS ENCONTRADOS, ' + nrow_in + ' DENTRO DE LA LOCALIDAD, ' + nrow_out + ' FUERA</p>';
      jQuery("#list_msg").html(html);
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
 
<form name="<portlet:namespace/>centrospoblados" id="<portlet:namespace/>centrospoblados"  method="post" style="background-color:white">
 <div id="welcome-image">
  <table style="width:940px;margin:0 auto;border:0">
    <tbody>
      <tr id="cm_mapTR">
        <td> <div id="<portlet:namespace/>map" style="overflow: hidden; width:940px; height:502px"><br><br>Cargando el Mapa - favor de ser paciente <br><br><br><img src=/osinergmin-theme/images/maps/ajax-loading.gif> </div> </td>
     </tr>
    </tbody>
  </table>
 </div>

 <div id="wrapper">
  <table style="width:940px;margin:0 10px 0 10px;border:0">
    <tr>
      <th>
        <h2 style="width:600px;margin-bottom:10px;text-align:center">B&uacute;squeda de Centros Poblados</h2>
      </th>
      <th>
        <h2 style="width:330px;margin-bottom:10px;background:#ccc;text-align:center">Resultados de la B&uacute;squeda</h2>
      </th>
    </tr>
    <tr>
      <td>
        <table width="100%" border="0">
          <tr>
            <td><strong>&nbsp;&nbsp;Semestre</strong></td>
            <td>
              <select name="semestre" id="<portlet:namespace/>semestre" style="width:190px;margin-left:20px;">
                <option value=""></option>
              </select>
            </td>
            <td rowspan="2">
              <input type="checkbox" checked="" value="show_set" id="<portlet:namespace/>chk_set"> SET
              <br />
              <input type="checkbox" checked="" value="show_sed" id="<portlet:namespace/>chk_sed"> SED
              <br />
            </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><strong>&nbsp;&nbsp;Empresa</strong></td>
            <td>
              <select name="empresa" id="<portlet:namespace/>empresa" style="width: 190px;margin-left:20px;">
                <option value=""></option>
              </select>                    
            </td>
            <td valign="bottom" style="align:baseline; margin-right:12px; float:right">
              <input type="button" id="<portlet:namespace/>buscar" value="Buscar" name="buscar" class="medium button grey">
            </td>
          </tr>
          <tr>
            <td><strong>&nbsp;&nbsp;Localidad</strong></td>
            <td>
              <select name="localidad" id="<portlet:namespace/>localidad" style="width: 190px;margin-left:20px;">
                <option value=""></option>
              </select>                    
            </td>
          </tr>
        </table>
      </td>
      <td> 
        <div id="result-header" class="hidden">
          <table width="100%" border="0">
            <tr>
              <td><strong>&nbsp;&nbsp;Localidad</strong></td>
              <td>
                <select name="list_localidad" id="<portlet:namespace/>list_localidad" style="width: 190px;margin-left:20px;">
                  <option value=""></option>
                </select>
              </td>
            </tr>
          </table>
        </div>
        <div id="result-detail" class="hidden">
          <table width="100%" border="0">
            <tr>
              <td colspan="2">
                <span id="list_msg">
                  <p>&nbsp;</p>
                </span> 
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <span id="export_link">
                  <a id="<portlet:namespace/>export_xls" href="#">
                    <p> Descargar Excel </p>
                  </a>
                </span>
              </td>
            </tr> 
          </table>
        </div>
      </td>
    </tr>
  </table>
 </div>
</form>