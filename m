From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc4 2/3] MAINTAINERS: mark the sk98lin driver as obsolete
Date: Tue, 18 Oct 2005 21:31:00 -0400
Message-ID: <10182005213100.12420@bilbo.tuxdriver.com>
References: <10182005213100.12360@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, mlindner@syskonnect.de,
	rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932436AbVJSBiG@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <10182005213100.12360@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk98lin and skge drivers cover the same set of hardware, and the
skge driver enjoys community support.  This patch marks the sk98lin
driver as obsolete.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 MAINTAINERS |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1592,7 +1592,7 @@ M: 	mlindner@syskonnect.de
 P:	Ralph Roesler
 M: 	rroesler@syskonnect.de
 W: 	http://www.syskonnect.com
-S: 	Supported
+S: 	Obsolete
 
 MAESTRO PCI SOUND DRIVERS
 P:	Zach Brown
