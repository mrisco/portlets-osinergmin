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
<script type="text/javascript" src="http://www.google.com/jsapi"></script>

<script type="text/javascript">
  /* Variables Globales - Google Maps */
  google.load('visualization', '1',{'packages':['corechart', 'table', 'geomap']});
  var map, layer_localidad, layer_sed;
  var key = 'AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4';
  var ft_localidad = '11l7q3ruvlJ3hI24hjgSSUgGhVLw1uNyC8UIDllY';
  var ft_localidad_id = 3110406;
  var ft_sed_id = 3109998;
  var buscar = false;
  
  jQuery(document).ready(function(){
      <portlet:namespace/>loadScript();
      <portlet:namespace/>initCombos();
      jQuery("#<portlet:namespace/>semestre").change(function() {<portlet:namespace/>initComboSemestre();});
      jQuery("#<portlet:namespace/>empresa").change(function() {<portlet:namespace/>initComboEmpresa();});
      jQuery("#<portlet:namespace/>localidad").change(function() {buscar = false;});
      jQuery("#<portlet:namespace/>buscar").click(function() {<portlet:namespace/>buscarDatos();});
      jQuery("#<portlet:namespace/>chk_sed").click(function() {<portlet:namespace/>habilitarLayers();});
      jQuery("#<portlet:namespace/>export_xls").click(function() {<portlet:namespace/>exportarExcel();});
      jQuery("#<portlet:namespace/>result_table").hide();
      jQuery("<div>Hi There!</div>").insertAfter("#<portlet:namespace/>followMe");
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
         <portlet:namespace/>filterMap();
      }
  }
  
  function <portlet:namespace/>buscarDatos() {
      buscar = true;
      <portlet:namespace/>filterMap();
      <portlet:namespace/>updateResults();
  }
  
  function <portlet:namespace/>filterMap() {
      var chk_sed = jQuery("#<portlet:namespace/>chk_sed").is(':checked');
      var chk_set = jQuery("#<portlet:namespace/>chk_set").is(':checked');
      var semestre = jQuery("#<portlet:namespace/>semestre option:selected").val();
      var empresa = jQuery("#<portlet:namespace/>empresa option:selected").val();
      var localidad = jQuery("#<portlet:namespace/>localidad option:selected").val();
      
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
  
  function <portlet:namespace/>updateResults() {
      var localidad = jQuery("#<portlet:namespace/>localidad option:selected").val();
      var html = '';
      var text = '';
      
      jQuery("#<portlet:namespace/>result_table").show();
      if (localidad == '') {
          html = jQuery("#<portlet:namespace/>localidad").html();
          jQuery("#<portlet:namespace/>list_localidad").html(html);
      } else {
          html = jQuery('#<portlet:namespace/>localidad option:selected').val();
          text = jQuery('#<portlet:namespace/>localidad option:selected').text();
          html = '<option value="' + html + '">' + text + '</option>';
          jQuery("#<portlet:namespace/>list_localidad").html(html);
      }
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
   
      for(i = 0; i < numRows; i++) {
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
      alert("MR");
  }
</script>

<style type="text/css">
div#welcome-image {
    width:100%;
    height:500px;
    margin:0;
    /*background-color: #ebebeb;*/
}
div#welcome-image img{display:block; margin-left:auto; margin-right:auto;}
div#wrapper{
    width:960px;
    /*margin:0 auto -170px;*/
    min-height: 100%;
    height: auto !important;
    height: 100%;
    padding:0;
    line-height:18px;
}
h2, h3, h4 {font-family: 'BenettonRegular', 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight:normal; text-transform:uppercase}
h2 {font-size:15px; line-heigth:15px;}
body {font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight:normal; font-size:12px; line-heigth:16px; color:#666}

/* Theme */
h2{ background:#009933; height:25px; line-height:25px; width:100%;color:#FFF;}
h2{ background:#004993;}

.button, .button:visited, .medium.button, .medium.button:visited { font-size: 12px; line-height: 12px; padding:5px 20px;}
.grey.button, .grey.button:visited  { background-color: #c2c2c2;color: #000; }
.grey.button:hover { background-color: #949494; color: #000;}
/*a h2, aside a h2{color:#FFF; text-decoration:none;width:100%;}*/
span#export_link p{ background:url(/osinergmin-theme/images/maps/logo-xls.png) 1% 50% no-repeat; height:30px; line-height:32px;padding-left:28px;}
span#list_msg p{ padding-top:8px;padding-left:5px;margin-bottom:0px}

a { color: #004993;text-decoration: none;}
a:hover { color: #ac0518;}
</style>

<!--<div id="lb_errorbusqueda">
  <div class="error_up"></div>
    <div class="error_center" style="width: 330px">
      <div class="error_mark">
        <div class="error_mark_img">
          <img src="/portalInmobiliario-theme/images/ibk/lb_error-mark.jpg" alt="" />
        </div>
        <div class="error_mark_cerrar">
          <p><a  onclick="lighBox.close('errorformulario');ponerfoco();"><img src="/portalInmobiliario-theme/images/ibk/lb_error_cerrar.jpg" width="16" height="15" alt=""/></a></p>
        </div>
    </div>
    <div class="error_cont"  id="<portlet:namespace />cuerpomsjerror">
    </div>
  </div>
  <div class="error_bottom"></div>
</div>-->
 
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
        <div id="<portlet:namespace/>result_table">
          <table width="100%" border="0">
            <tr>
              <td><strong>&nbsp;&nbsp;Localidad</strong></td>
              <td>
                <select name="list_localidad" id="<portlet:namespace/>list_localidad" style="width: 190px;margin-left:20px;">
                  <option value=""></option>
                </select>
              </td>
            </tr> 
            <tr>
              <td colspan="2">
                <span id="list_msg">
                  <p>12 SEDS ENCONTRADOS</p>
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


<!--This is the <h1>CentrosPoblados XXX</h1> portlet in View mode.-->
<!--<div id="<portlet:namespace/>followMe">Follow me!</div>

<div class="main_form">
  <input type="button" id="<portlet:namespace/>consultar" value="Consultar" /> 
</div>-->