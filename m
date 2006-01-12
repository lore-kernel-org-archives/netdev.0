From: Alex Shepard <ashepard@u.washington.edu>
Subject: [PATCH] Spelling fix in IPW2100 and IPW2200 Kconfig entries
Date: Thu, 12 Jan 2006 14:15:13 -0800
Message-ID: <1137104113.15772.17.camel@athena>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	trivial@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161361AbWALWP0@vger.kernel.org>
To: jketreno@linux.intel.com, yi.zhu@intel.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/remvoed/removed/


Signed-off-by: Alex Shepard <ashepard@u.washington.edu>

--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -160,7 +160,7 @@ config IPW2100
           <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
  
           If you want to compile the driver as a module ( = code which can be
-          inserted in and remvoed from the running kernel whenever you want),
+          inserted in and removed from the running kernel whenever you want),
           say M here and read <file:Documentation/modules.txt>.  The module
           will be called ipw2100.ko.
 	
@@ -213,7 +213,7 @@ config IPW2200
           <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
  
           If you want to compile the driver as a module ( = code which can be
-          inserted in and remvoed from the running kernel whenever you want),
+          inserted in and removed from the running kernel whenever you want),
           say M here and read <file:Documentation/modules.txt>.  The module
           will be called ipw2200.ko.
 
