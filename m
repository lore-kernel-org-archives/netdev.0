From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] net: correct-Traffic-shaper-Kconfig
Date: Sat, 29 Jul 2006 15:57:43 -0400
Message-ID: <fbdc1c0c5508c52eeb27a182b661ac1c460d91c0@hohoho>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932224AbWG2T5o@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

correct-Traffic-shaper-Kconfig

Correct traffic shaper Kconfig text.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit fbdc1c0c5508c52eeb27a182b661ac1c460d91c0
tree 84995c9113a19ae1c104579b96e311f34a94bda9
parent fb63c3d00f6990e66752e05f98f13ff464e97b42
author Jiri Slaby <ku@bellona.localdomain> Sat, 08 Apr 2006 15:20:41 +0159
committer Jiri Slaby <ku@bellona.localdomain> Sat, 08 Apr 2006 15:20:41 +0159

 drivers/net/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 15d4161..c5030db 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2802,9 +2802,9 @@ config SHAPER
 	  these virtual devices. See
 	  <file:Documentation/networking/shaper.txt> for more information.
 
-	  An alternative to this traffic shaper is the experimental
-	  Class-Based Queuing (CBQ) scheduling support which you get if you
-	  say Y to "QoS and/or fair queuing" above.
+	  An alternative to this traffic shaper is the Class-Based Queuing
+	  (CBQ) scheduling support which you get if you say Y to
+	  "QoS and/or fair queuing" in "Networking options".
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called shaper.  If unsure, say N.
