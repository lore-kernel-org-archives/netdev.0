From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 04/27] Documentation/networking/igbvf.txt: Update documentation
Date: Fri, 10 Dec 2010 01:50:44 -0800
Message-ID: <1291974667-30254-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:43072 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751114Ab0LJJ5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 04:57:01 -0500
To: davem@davemloft.net
In-Reply-To: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN igbvf documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/igbvf.txt |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/igbvf.txt b/Documentation/networking/igbvf.txt
index 0560281..694817b 100644
--- a/Documentation/networking/igbvf.txt
+++ b/Documentation/networking/igbvf.txt
@@ -58,7 +58,9 @@ Additional Configurations
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 3.0 or later is required for this functionality, although we
+  strongly recommend downloading the latest version at:
 
   http://sourceforge.net/projects/gkernel.
 
-- 
1.7.3.2

