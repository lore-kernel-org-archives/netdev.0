From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/27] Documentation/networking/ixgbevf.txt: Update documentation
Date: Fri, 10 Dec 2010 01:50:46 -0800
Message-ID: <1291974667-30254-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:38746
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751486Ab0LJJ5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 04:57:06 -0500
To: davem@davemloft.net
In-Reply-To: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN ixgbevf documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/ixgbevf.txt |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/ixgbevf.txt
index 21dd5d1..5a91a41 100644
--- a/Documentation/networking/ixgbevf.txt
+++ b/Documentation/networking/ixgbevf.txt
@@ -35,10 +35,6 @@ Driver ID Guide at:
 Known Issues/Troubleshooting
 ============================
 
-  Unloading Physical Function (PF) Driver Causes System Reboots When VM is
-  Running and VF is Loaded on the VM
-  ------------------------------------------------------------------------
-  Do not unload the PF driver (ixgbe) while VFs are assigned to guests.
 
 Support
 =======
-- 
1.7.3.2

