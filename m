From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] [trivial] net: wan: sbni: Spelling s/acknoweledge/acknowledge/, Grammar
Date: Wed, 31 Aug 2016 11:41:22 +0200
Message-ID: <1472636482-27408-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/wan/sbni.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index d98c7e57137d22ed..60db7c5e611b2048 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -582,8 +582,8 @@ handle_channel( struct net_device  *dev )
 
 
 /*
- * Routine returns 1 if it need to acknoweledge received frame.
- * Empty frame received without errors won't be acknoweledged.
+ * Routine returns 1 if it needs to acknowledge received frame.
+ * Empty frame received without errors won't be acknowledged.
  */
 
 static int
-- 
1.9.1
