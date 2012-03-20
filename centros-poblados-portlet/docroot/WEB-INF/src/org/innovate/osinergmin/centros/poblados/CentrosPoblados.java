package org.innovate.osinergmin.centros.poblados;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.IndexedColors;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;

/**
 * Portlet implementation class CentrosPoblados
 */
public class CentrosPoblados extends MVCPortlet {
  private static Log _log = LogFactoryUtil.getLog(CentrosPoblados.class);

  @Override
  public void render(RenderRequest renderRequest, RenderResponse renderResponse)
      throws PortletException, IOException {
    _log.info("Entrando a la función render");
    super.render(renderRequest, renderResponse);
  }

  @Override
  public void serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
      throws IOException, PortletException {
    _log.info("Entrando a la función serverResource");
    String metodo = resourceRequest.getParameter("metodo");
    _log.info("Metodo: " + metodo);

    if (metodo != null) {
      if (metodo.equals("excel")) {
        try {
          generarExcel(resourceRequest, resourceResponse);
        } catch (Exception e) {
          System.out.println("Error al generar el archivo Excel");
          System.out.println(e.toString());
        }
      } else if (metodo.equals("json")) {
        validateJSON(resourceRequest, resourceResponse);
      }
    }

  }

  private void validateJSON(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
      throws IOException {
    resourceResponse.setContentType("application/json");
    JSONObject object = JSONFactoryUtil.createJSONObject();
    // String respuesta = "9";
    // object.put("salida",respuesta);
    object.put("salida", 9);
    PrintWriter pw = resourceResponse.getWriter();
    pw.write(object.toString());
    pw.flush();
    pw.close();
  }

  private void generarExcel(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
      throws Exception {
    String arrayDatos = resourceRequest.getParameter("arrayDatos");
    String ncol = resourceRequest.getParameter("ncol");
    String nrow = resourceRequest.getParameter("nrow");
    String[] vector = (arrayDatos == null) ? null : arrayDatos.split("\\|");
    int i, j, k;

    System.out.println(arrayDatos);
    System.out.println("vector " + vector.length);
    resourceResponse.setContentType("application/octet-stream");
    resourceResponse.setProperty("Content-Disposition", "attachment; filename=ListadoSED.xls");

    String[] cabecera = { "Nombre-SED", "SED", "Semestre", "Empresa", "Localidad", "Contenido" };
    HSSFWorkbook wb = new HSSFWorkbook();
    // Se crea una Hoja dentro del Libro
    HSSFSheet hoja = wb.createSheet("ListadoSED");
    // Se crea una Fila dentro de la Hoja
    HSSFRow fila = null;
    // Se crea una Celda dentro de la Fila
    HSSFCell celda = null;
    HSSFRichTextString texto = null;
    // Se crea inicialmente la Cabecera
    fila = hoja.createRow(0);
    for (j = 0; j < cabecera.length; j++) {
      celda = fila.createCell(j, HSSFCell.CELL_TYPE_STRING);
      texto = new HSSFRichTextString(cabecera[j]);
      celda.setCellValue(texto);
      HSSFCellStyle style = wb.createCellStyle();
      style.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
      style.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
      HSSFFont font = wb.createFont();
      font.setFontHeightInPoints((short) 10);
      font.setFontName("Courier New");
      font.setItalic(true);
      style.setFont(font);
      celda.setCellStyle(style);
    }

    // Se crean las Celdas del contenido
    if (vector != null) {
      k = Integer.parseInt(ncol);
      for (i = 0; i < Integer.parseInt(nrow); i++) {
        fila = hoja.createRow(i + 1);
        // Nombre_Sed
        celda = fila.createCell(0, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k]);
        // Sed
        celda = fila.createCell(1, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k + 1]);
        // Semestre
        celda = fila.createCell(2, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k + 2]);
        // Empresa
        celda = fila.createCell(3, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k + 3]);
        // Localidad
        celda = fila.createCell(4, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k + 4]);
        // Contenido
        celda = fila.createCell(5, HSSFCell.CELL_TYPE_STRING);
        celda.setCellValue(vector[i * k + 5]);
      }
    }

    OutputStream os = resourceResponse.getPortletOutputStream();
    wb.write(os);
    os.flush();
    os.close();
  }
}
