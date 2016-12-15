From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 3/3] MAINTAINERS: net: add entry for Freescale QorIQ DPAA
 Ethernet driver
Date: Thu, 15 Dec 2016 15:13:06 +0200
Message-ID: <1481807586-4798-4-git-send-email-madalin.bucur@nxp.com>
References: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Add record for Freescale QORIQ DPAA Ethernet driver adding myself as
maintainer.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e2463ba..0ff9757 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5058,6 +5058,12 @@ S:	Maintained
 F:	drivers/net/ethernet/freescale/fman
 F:	Documentation/devicetree/bindings/powerpc/fsl/fman.txt
 
+FREESCALE QORIQ DPAA ETHERNET DRIVER
+M:	Madalin Bucur <madalin.bucur@nxp.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/freescale/dpaa
+
 FREESCALE QUICC ENGINE LIBRARY
 L:	linuxppc-dev@lists.ozlabs.org
 S:	Orphan
-- 
2.1.0
