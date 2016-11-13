From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [net-next 2/2] MAINTAINERS: add entry for slicoss ethernet driver
Date: Sun, 13 Nov 2016 05:47:33 +0100
Message-ID: <1479012453-19410-3-git-send-email-LinoSanfilippo@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
 gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Add myself as maintainer for the slicoss ethernet driver.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 MAINTAINERS | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6781a3f..bb9af28 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -562,6 +562,11 @@ T:	git git://linuxtv.org/anttip/media_tree.git
 S:	Maintained
 F:	drivers/media/usb/airspy/
 
+ALACRITECH GIGABIT ETHERNET DRIVER
+M:	Lino Sanfilippo <LinoSanfilippo@gmx.de>
+S:	Maintained
+F:	drivers/net/ethernet/alacritech/*
+
 ALCATEL SPEEDTOUCH USB DRIVER
 M:	Duncan Sands <duncan.sands@free.fr>
 L:	linux-usb@vger.kernel.org
-- 
1.9.1
