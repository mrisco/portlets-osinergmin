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
<script type="text/javascript" src="/llamadas-telefonicas-portlet/js/jquery.tablePagination.0.5.js"></script>

<link href='/osinergmin-theme/css/portlet-osinergmin.css' type=text/css rel=stylesheet>
<link href='/llamadas-telefonicas-portlet/css/tablePagination.css' type=text/css rel=stylesheet>

<script type="text/javascript">
  /* Variables Globales - Google Maps */
  google.load('visualization', '1',{'packages':['corechart', 'table', 'geomap']});
  var key = 'AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4';
  var map, layer_localidad, layer_sed, widget;
  var ft_localidad = 3110406;
  var ft_sed = 3109998;
  var tablePagination = false;
  var vector_excel = new Array();
  var ncol_excel = 0, nrow_excel = 0;
  
  jQuery(document).ready(function(){
      <portlet:namespace/>loadScript();
      <portlet:namespace/>initCombos();
      jQuery("#<portlet:namespace/>semestre").change(function() {<portlet:namespace/>initComboSemestre();});
      jQuery("#<portlet:namespace/>buscar").click(function() {<portlet:namespace/>buscarDatos();});
      jQuery("#<portlet:namespace/>export_xls").click(function() {<portlet:namespace/>exportarExcel();});
      jQuery("#<portlet:namespace/>export_xls").attr("disabled", true);
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
      script.src = "/llamadas-telefonicas-portlet/js/distanceWidget.js";
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
  }
  
  function <portlet:namespace/>fillCombos(result) {
      var html = '<option value="">- Seleccionar un Semestre -' + <portlet:namespace/>parseResultQuery(result, 'semestre', 'nombre_semestre');
      
      jQuery("#<portlet:namespace/>semestre").html(html);
      html = '<option value="">- Seleccionar una Empresa -</option>';
      jQuery("#<portlet:namespace/>empresa").html(html);
  }
  
  function <portlet:namespace/>fillComboSemestre(result) {
      var html = '<option value="">- Seleccionar una Empresa -</option>' + <portlet:namespace/>parseResultQuery(result, 'empresa', 'nombre_empresa');
      
      jQuery("#<portlet:namespace/>empresa").html(html);
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
  
  function <portlet:namespace/>buscarDatos() {
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      
      if (semestre == ''){
         var addhtml='<p class="error_warning">No se ha ingresado correctamente los datos</p>';
         addhtml+='<p class="error_msj">Debe seleccionar un valor para Semestre</p>';
         jQuery("#<portlet:namespace />cuerpomsjerror").html(addhtml);
         lighBox.open('errorbusqueda');
      } else {
         <portlet:namespace/>filterMap();
         if (widget == null) {
            widget = new DistanceWidget({
                distance: 20, // Starting distance in km.
                maxDistance: 2500, // Twitter has a max distance of 2500km.
                color: '#000000',
                activeColor: '#5599bb',
                icon: new google.maps.MarkerImage('/llamadas-telefonicas-portlet/images/symbol_blank.png'),
                sizerIcon: new google.maps.MarkerImage('/llamadas-telefonicas-portlet/images/resize-off.png'),
                activeSizerIcon: new google.maps.MarkerImage('/llamadas-telefonicas-portlet/images/resize.png')
            });
            
            /* add event for resizing border */
            google.maps.event.addListener(widget, 'active_changed', function() {
                if(!widget.get('active')){
                    <portlet:namespace/>filterWidget(widget);
                }
            });
            
            /* add event for moving center */
            google.maps.event.addListener(widget, 'dragend_changed', function() {
                if(widget.get('dragend')){
                    <portlet:namespace/>filterWidget(widget);
                }
            });
         }
      }
  }
  
  function <portlet:namespace/>filterMap() {
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      
      var where = '';
      if (semestre != '') {
         where = where + 'semestre = \'' + semestre + '\'';
      }
      if (empresa != '') {
         where = where + ' and empresa = \'' + empresa + '\'';
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
                from: ft_localidad,
                where: where
            }
          }
      
      var option_sed = {
         map: map,
         query: {
             select: 'geometry',
             from: ft_sed,
             where: where
         }
      }
      
      // Aplicamos el zoom de la busqueda
      var query_zoom = "SELECT geometry FROM " + ft_localidad + " WHERE " + where;
      <portlet:namespace/>zoom2query(query_zoom);
      
      layer_localidad.setOptions(option_localidad);
      layer_sed.setOptions(option_sed);
  }
  
  function <portlet:namespace/>filterWidget(widget) {
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      
      var where = 'ST_INTERSECTS(geometry, CIRCLE( LATLNG'+ widget.get('position') + ' , ' + widget.get('distance') * 1000 + ')) AND ';
      if (semestre != '') {
         where = where + 'semestre = \'' + semestre + '\'';
      }
      if (empresa != '') {
         where = where + ' and empresa = \'' + empresa + '\'';
      }

      layer_sed.setOptions({
          query: {
              select: 'geometry',
              from: ft_sed,
              where: where
            }
          });
      
      /* update table result */
      <portlet:namespace/>updateResult(where);
  }
  
  /*
   * Funciones usadas para actualizar el div box_result
   */
  function <portlet:namespace/>updateResult(where) {
      var sql = 'SELECT sed, nombre_sed, empresa FROM ' + ft_sed + ' WHERE ' + where + ' ORDER BY sed';
      ft2json.query(sql, <portlet:namespace/>fillTableResult);    
  }
  
  function <portlet:namespace/>fillTableResult(result) {
      var html = "<table><thead><tr><th>Sed</th><th>Nombre Sed</th><th>Empresa</th></tr></thead><tbody>";
      html = html + <portlet:namespace/>parseResultTable(result) + '</tbody></table>';

      jQuery("#<portlet:namespace/>export_xls").attr("disabled", false);
      jQuery("#table_result").html(html);
      jQuery("#table_result tr:odd").addClass("odd");
      if (!tablePagination) { 
         tablePagination = true;
         jQuery("#table_result").tablePagination({width:330, height:210, topNav:false});
      } else {
         var rowsPerPage = parseInt(jQuery("#tablePagination_rowsPerPage option:selected").val(),10);
         jQuery("#tablePagination_head").remove();
         jQuery("#tablePagination").remove();
         jQuery("#table_result").tablePagination({width:330, height:210, topNav:false, divTable:false, rowsPerPage:rowsPerPage});
      }
  }
  
  function <portlet:namespace/>parseResultTable(result) {
      var sed = 'sed', nombre_sed = 'nombre_sed', empresa = 'empresa';
      var val_sed = '', val_nombre_sed = '', val_empresa = '';
      var ncol = 3, nrow = 0, index = 0;
      var vector = new Array();
      var html = '';
      
      for(i in result) {
          if(i == 'data') {
              for(var j = 0; j < result[i].length; j++) {
                  for(k in result[i][j]) {
                      if (k == sed) { val_sed = result[i][j][k]; }
                      if (k == nombre_sed) { val_nombre_sed = result[i][j][k]; }
                      if (k == empresa) { val_empresa = result[i][j][k]; }
                  }
                  index = nrow*ncol;
                  vector[index+0] = val_sed;
                  vector[index+1] = val_nombre_sed;
                  vector[index+2] = val_empresa;
                  nrow++;
                  
                  html = html + '<tr><td>' + val_sed + '</td><td>' + val_nombre_sed + '</td><td>' + val_empresa + '</td></tr>';
              }
          }
      }
      vector_excel = vector;
      nrow_excel = nrow; ncol_excel = ncol;
      return html;
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
      
      /* center the widget */
      widget.set('position', map.getCenter());
      widget.set('distance', 20);
      if ( !widget.get('map') ) {
         widget.set('map', map);
      }
      /* first filter widget */
      <portlet:namespace/>filterWidget(widget);
  }
  
  function <portlet:namespace/>exportarExcel() {
      /* Llamada para al portlet para la generacion del archivo excel */
      var url='<portlet:resourceURL></portlet:resourceURL>';
      //jQuery.post(url, {arrayDatos:vector, ncol:ncol, nrow:nrow, metodo:"excel"});
      var frm = document.<portlet:namespace/>llamadastelefonicas;
      frm.action=url+'&metodo=excel&arrayDatos='+vector_excel.join('|')+'&ncol='+ncol_excel+'&nrow='+nrow_excel;
      frm.submit();
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

<form name="<portlet:namespace/>llamadastelefonicas" id="<portlet:namespace/>llamadastelefonicas"  method="post" style="background-color:white">
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
         <td style="width:32%">
           <strong>&nbsp;&nbsp;&nbsp;&nbsp;Semestre</strong>
         </td>
         <td style="width:68%">
           <select name="semestre" id="<portlet:namespace/>semestre" style="width:190px;margin-left:20px;">
             <option value=""></option>
           </select>
         </td>
       </tr>
       <tr>
         <td style="width:32%">
           <strong>&nbsp;&nbsp;&nbsp;&nbsp;Empresa</strong>
         </td>
         <td style="width:68%">
           <select name="empresa" id="<portlet:namespace/>empresa" style="width: 190px;margin-left:20px;">
             <option value=""></option>
           </select>                    
         </td>
       </tr>
     </table><br>
     <table width="100%" border="0">
       <tr>
         <td align="right" style="width:40%">
           <input type="button" id="<portlet:namespace/>buscar" value="Buscar" name="buscar" class="medium button grey">
         </td>
         <td align="center" style="width:60%">
           <input type="button" id="<portlet:namespace/>export_xls" value="Exportar Excel" name="export_xls" class="medium button grey">
         </td>
       </tr>
     </table>
   </div>
   <div id="box_result_bottom">
     <h2 style="width:330px;margin-bottom:10px;background:#ccc;text-align:center">Resultados de la B&uacute;squeda</h2>
     <table id="table_result"></table>
   </div>
 </div>
</form>