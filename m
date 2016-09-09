From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 2/9] MAINTAINERS: Add myself as maintainer of sun8i-emac
Date: Fri,  9 Sep 2016 14:45:10 +0200
Message-ID: <1473425117-18645-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: robh+dt@kernel.org, mark.rutland@arm.com, maxime.ripard@free-electrons.com,
 wens@csie.org, linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch add myself as maintainer of the sun8i-emac driver.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6781a3f..43f5be3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -582,6 +582,12 @@ S:	Maintained
 F:	Documentation/i2c/busses/i2c-ali1563
 F:	drivers/i2c/busses/i2c-ali1563.c
 
+ALLWINNER SUN8I-EMAC ETHERNET DRIVER
+M:	Corentin Labbe <clabbe.montjoie@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/allwinner/sun8i-emac.c
+
 ALLWINNER SECURITY SYSTEM
 M:	Corentin Labbe <clabbe.montjoie@gmail.com>
 L:	linux-crypto@vger.kernel.org
-- 
2.7.3
