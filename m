From: Alan Ott <alan@signal11.us>
Subject: [PATCH net-next] MAINTAINERS: Add section for MRF24J40 IEEE 802.15.4 radio driver
Date: Sat, 16 Aug 2014 17:09:03 -0400
Message-ID: <1408223343-6031-1-git-send-email-alan@signal11.us>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: "David S. Miller" <davem@davemloft.net>,
	Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan is the original author of the driver. This change was discussed
with the 802.15.4 subsystem maintainer, Alexander Aring.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2f85f55..c066da4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5972,6 +5972,12 @@ T:	git git://linuxtv.org/media_tree.git
 S:	Maintained
 F:	drivers/media/radio/radio-mr800.c
 
+MRF24J40 IEEE 802.15.4 RADIO DRIVER
+M:	Alan Ott <alan@signal11.us>
+L:	linux-wpan@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ieee802154/mrf24j40.c
+
 MSI LAPTOP SUPPORT
 M:	"Lee, Chun-Yi" <jlee@suse.com>
 L:	platform-driver-x86@vger.kernel.org
-- 
1.8.1.2
