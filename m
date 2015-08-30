From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next v2 1/8] net: thunderx: fix MAINTAINERS
Date: Sun, 30 Aug 2015 12:29:09 +0300
Message-ID: <1440926958-1874-2-git-send-email-aleksey.makarov@auriga.com>
References: <1440926958-1874-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@auriga.com>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Alexey Klimov <klimov.linux@gmail.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440926958-1874-1-git-send-email-aleksey.makarov@auriga.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>

The liquidio and thunder drivers have different maintainers.

Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4e6dcb6..43cf79e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -928,7 +928,7 @@ M:	Sunil Goutham <sgoutham@cavium.com>
 M:	Robert Richter <rric@kernel.org>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 S:	Supported
-F:	drivers/net/ethernet/cavium/
+F:	drivers/net/ethernet/cavium/thunder/
 
 ARM/CIRRUS LOGIC CLPS711X ARM ARCHITECTURE
 M:	Alexander Shiyan <shc_work@mail.ru>
@@ -2543,7 +2543,6 @@ M:     Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
 L:     netdev@vger.kernel.org
 W:     http://www.cavium.com
 S:     Supported
-F:     drivers/net/ethernet/cavium/
 F:     drivers/net/ethernet/cavium/liquidio/
 
 CC2520 IEEE-802.15.4 RADIO DRIVER
-- 
2.5.0
