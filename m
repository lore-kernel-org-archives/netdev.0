From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Kconfig: STRIP: Remove stale bits of STRIP help text
Date: Thu, 1 Oct 2009 23:48:09 +0200
Message-ID: <20091001214809.GA15234@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:60646 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbZJAVrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:47:08 -0400
Received: from localhost.localdomain ([127.0.0.1]:47275 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-FAIL) by ftp.linux-mips.org with ESMTP
	id S1493490AbZJAVrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 23:47:06 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove references to dead web site mosquitonet.Stanford.EDU.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/wireless/Kconfig |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 49ea9c9..d7a764a 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -31,13 +31,12 @@ config STRIP
 	---help---
 	  Say Y if you have a Metricom radio and intend to use Starmode Radio
 	  IP. STRIP is a radio protocol developed for the MosquitoNet project
-	  (on the WWW at <http://mosquitonet.stanford.edu/>) to send Internet
-	  traffic using Metricom radios.  Metricom radios are small, battery
-	  powered, 100kbit/sec packet radio transceivers, about the size and
-	  weight of a cellular telephone. (You may also have heard them called
-	  "Metricom modems" but we avoid the term "modem" because it misleads
-	  many people into thinking that you can plug a Metricom modem into a
-	  phone line and use it as a modem.)
+	  to send Internet traffic using Metricom radios.  Metricom radios are
+	  small, battery powered, 100kbit/sec packet radio transceivers, about
+	  the size and weight of a cellular telephone. (You may also have heard
+	  them called "Metricom modems" but we avoid the term "modem" because
+	  it misleads many people into thinking that you can plug a Metricom
+	  modem into a phone line and use it as a modem.)
 
 	  You can use STRIP on any Linux machine with a serial port, although
 	  it is obviously most useful for people with laptop computers. If you
