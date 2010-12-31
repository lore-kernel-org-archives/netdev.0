From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 2/7] net/sungem.h Typo change desciptor to descriptor.
Date: Fri, 31 Dec 2010 09:38:44 -0800
Message-ID: <1293817124-7980-1-git-send-email-justinmattock@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Below is a patch, that changes a typo from "desciptor" to "descriptor".
Let me know if I missed anything.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/net/sungem.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index 1990546..bfb6683 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -843,7 +843,7 @@ struct gem_txd {
 
 /* GEM requires that RX descriptors are provided four at a time,
  * aligned.  Also, the RX ring may not wrap around.  This means that
- * there will be at least 4 unused desciptor entries in the middle
+ * there will be at least 4 unused descriptor entries in the middle
  * of the RX ring at all times.
  *
  * Similar to HME, GEM assumes that it can write garbage bytes before
-- 
1.6.5.2.180.gc5b3e
