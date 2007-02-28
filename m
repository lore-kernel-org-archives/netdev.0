From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  Second try at vlan mailing list patch.
Date: Wed, 28 Feb 2007 15:25:59 -0800
Message-ID: <45E60F87.3070708@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000206030400020006010602"
Cc: "David S. Miller" <davem@davemloft.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:47746 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbXB1X0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 18:26:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000206030400020006010602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hopefully, by attaching it as a file it will not screw up the tabs & spaces.

Signed-off-by:  Ben Greear <greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000206030400020006010602
Content-Type: text/x-patch;
 name="vlan_ml.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan_ml.patch"

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 18fcb9f..c4209c8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -3,7 +3,8 @@
  *		Ethernet-type device handling.
  *
  * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
+ *              Please send support related email to: vlan@candelatech.com
+ *                after subscribing using the link below.
  *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
  * 
  * Fixes:
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e49e252..203cd54 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -3,7 +3,8 @@
  *		Ethernet-type device handling.
  *
  * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
+ *              Please send support related email to: vlan@candelatech.com
+ *                after subscribing using the web page below.
  *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
  * 
  * Fixes:       Mar 22 2001: Martin Bokaemper <mbokaemper@unispherenetworks.com>

--------------000206030400020006010602--
