From: Jeff Garzik <jeff@garzik.org>
Subject: [git patch] net driver "fix"
Date: Wed, 6 Sep 2006 11:29:31 -0400
Message-ID: <20060906152931.GA23330@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:32493 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1751445AbWIFP3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:29:36 -0400
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Minor, but should go for 2.6.18.


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Brice Goglin:
      myri10ge: update the firmware download URL in Kconfig

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 30b3671..a2bd811 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2393,7 +2393,7 @@ config MYRI10GE
 	  you will need a newer firmware image.
 	  You may get this image or more information, at:
 
-	  <http://www.myri.com/Myri-10G/>
+	  <http://www.myri.com/scs/download-Myri10GE.html>
 
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module
