package org.innovate.osinergmin.centros.poblados;

import java.io.IOException;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

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
  }

  @Override
  public void serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
      throws IOException, PortletException {
    _log.info("Entrando a la función serverResource");
  }
}
