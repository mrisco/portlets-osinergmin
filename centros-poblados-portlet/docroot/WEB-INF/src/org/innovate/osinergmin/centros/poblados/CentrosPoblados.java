package org.innovate.osinergmin.centros.poblados;

import java.io.IOException;
import java.io.PrintWriter;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

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

    resourceResponse.setContentType("application/json");
    JSONObject object = JSONFactoryUtil.createJSONObject();
    // String respuesta = "9";
    // object.put("salida", respuesta);
    object.put("salida", 9);
    PrintWriter pw = resourceResponse.getWriter();
    pw.write(object.toString());
    pw.flush();
    pw.close();

  }
}
