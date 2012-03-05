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
      <portlet:namespace/>initCombos();
      jQuery("#<portlet:namespace/>semestre").change(function() {<portlet:namespace/>initComboSemestre();});
      jQuery("#<portlet:namespace/>empresa").change(function() {<portlet:namespace/>initComboEmpresa();});
      jQuery("#<portlet:namespace/>buscar").click(function() {<portlet:namespace/>buscarDatos();});
      jQuery("<div>Hi There!</div>").insertAfter("#<portlet:namespace/>followMe");
  });
  
  function <portlet:namespace/>loadScript() {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyBgDcbt6euvDzAMKy0uvaJ0qCuSSAP4XK4&sensor=false&callback=<portlet:namespace/>initialize";
      document.body.appendChild(script);  
  }
  
  function <portlet:namespace/>initialize() {
      var myLatlng = new google.maps.LatLng('-12.491991', '-76.72588');
      var myOptions = {
          zoom: 6,
          center: myLatlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
      }
      var map = new google.maps.Map(document.getElementById("<portlet:namespace/>map"), myOptions);
        
      var marker = new google.maps.Marker({
          position: myLatlng, 
          map: map,
          title:"MiMarcador"
      });
  }
  
  function <portlet:namespace/>initCombos() {
      ft2json.query('SELECT semestre, nombre_semestre FROM 11l7q3ruvlJ3hI24hjgSSUgGhVLw1uNyC8UIDllY ORDER BY semestre', <portlet:namespace/>fillCombos);
  }
  
  function <portlet:namespace/>initComboSemestre() {
      var semestre = jQuery('#<portlet:namespace/>semestre option:selected').val();
      var sql = 'SELECT empresa, nombre_empresa FROM 11l7q3ruvlJ3hI24hjgSSUgGhVLw1uNyC8UIDllY WHERE semestre = ' + semestre + ' ORDER BY empresa';
      ft2json.query(sql, <portlet:namespace/>fillComboSemestre);
  }

  function <portlet:namespace/>initComboEmpresa() {
      var empresa = jQuery('#<portlet:namespace/>empresa option:selected').val();
      var semestre = jQuery('#<portlet:namespace/>semestre option:selected').val();
      var sql = 'SELECT name, description FROM 11l7q3ruvlJ3hI24hjgSSUgGhVLw1uNyC8UIDllY WHERE empresa = \'' + empresa + '\' AND semestre = ' + semestre + ' ORDER BY name';
      ft2json.query(sql, <portlet:namespace/>fillComboEmpresa);
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
      var html = '<option value="">- Seleccionar una Localidad -</option>' + <portlet:namespace/>parseResultQuery(result, 'name', 'description');
      
      jQuery("#<portlet:namespace/>localidad").html(html);
  }
  
  /*
   * Función que devuelve el contenido HTML de un ComboBox, a partir del resultado de la query a una FusionTable, se asume que el resultado esta ordenado (SQL ORDER BY)
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
</style>

<div id="welcome-image">
  <table style="width:940px;margin:0 auto;border:0">
    <tbody>
      <tr id="cm_mapTR">
        <td> <div id="<portlet:namespace/>map" style="overflow: hidden; width:940px; height:502px"><br><br>Cargando el Mapa - favor de ser paciente <br><br><br><img src=http://www.benetton.com/wp-content/themes/benetton/images/ajax-loading.gif> </div> </td>
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
              <input type="checkbox" checked="" value="store_adult" id="chk_1" name="chk-01"> SET
              <br />
              <input type="checkbox" checked="" value="store_kid"   id="chk_2" name="chk-01"> SED
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
    </tr>
  </table>
</div>


<!--This is the <h1>CentrosPoblados XXX</h1> portlet in View mode.-->
<!--<div id="<portlet:namespace/>followMe">Follow me!</div>

<div class="main_form">
  <input type="button" id="<portlet:namespace/>consultar" value="Consultar" /> 
</div>-->