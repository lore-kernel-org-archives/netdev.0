From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-2.6] slcan: fix referenced website in Kconfig help text
Date: Sat, 29 Jan 2011 19:08:06 +0100
Message-ID: <4D445786.70701@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:44020 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab1A2SIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 13:08:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the referenced project website to www.mictronics.de in the Kconfig help
text for the slcan driver.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 986195e..5dec456 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -23,7 +23,7 @@ config CAN_SLCAN
 
 	  As only the sending and receiving of CAN frames is implemented, this
 	  driver should work with the (serial/USB) CAN hardware from:
-	  www.canusb.com / www.can232.com / www.mictronic.com / www.canhack.de
+	  www.canusb.com / www.can232.com / www.mictronics.de / www.canhack.de
 
 	  Userspace tools to attach the SLCAN line discipline (slcan_attach,
 	  slcand) can be found in the can-utils at the SocketCAN SVN, see

