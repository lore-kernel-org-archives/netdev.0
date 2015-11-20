From: Grant Grundler <grantgrundler@gmail.com>
Subject: [PATCH] net: tulip: update MAINTAINER status to Orphan
Date: Thu, 19 Nov 2015 17:56:12 -0800
Message-ID: <1447984572-23959-1-git-send-email-grantgrundler@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Helge Deller <deller@gmx.de>,
	Grant Grundler <grundler@parisc-linux.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

I haven't had any PCI tulip HW for the past ~5 years. I have
been reviewing tulip patches and can continue doing that.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
---
I'm also proposing to add linux-parisc to the list since AFAIK, all
parisc systems but the C8000 workstations (PA8800/PA8900 CPU)
use tulip for onboard LAN.

Specific mips and alpha systems also care about tulip driver too.
But I don't know either well enough to suggest respective mailing
lists should see every tulip patch.

 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea17512..ec07061 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10888,9 +10888,9 @@ S:	Maintained
 F:	drivers/media/tuners/tua9001*
 
 TULIP NETWORK DRIVERS
-M:	Grant Grundler <grundler@parisc-linux.org>
 L:	netdev@vger.kernel.org
-S:	Maintained
+L:	linux-parisc@vger.kernel.org
+S:	Orphan
 F:	drivers/net/ethernet/dec/tulip/
 
 TUN/TAP driver
-- 
2.6.0.rc2.230.g3dd15c0
