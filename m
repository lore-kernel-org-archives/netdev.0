From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] myri10ge: update MAINTAINERS
Date: Thu, 19 Jul 2012 23:11:13 -0700
Message-ID: <1342764673-16671-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46994 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173Ab2GTGKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 02:10:50 -0400
Received: by pbbrp8 with SMTP id rp8so5630757pbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 23:10:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove myself from myri10ge MAINTAINERS list

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 MAINTAINERS |    1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index f93b8ff..fe57950 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4586,7 +4586,6 @@ S:	Maintained
 F:	drivers/usb/musb/
 
 MYRICOM MYRI-10G 10GbE DRIVER (MYRI10GE)
-M:	Jon Mason <mason@myri.com>
 M:	Andrew Gallatin <gallatin@myri.com>
 L:	netdev@vger.kernel.org
 W:	http://www.myri.com/scs/download-Myri10GE.html
-- 
1.7.9.5
