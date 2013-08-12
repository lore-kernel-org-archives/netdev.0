From: Hyong-Youb Kim <hykim@myri.com>
Subject: [PATCH] myri10ge: Update MAINTAINERS
Date: Mon, 12 Aug 2013 02:20:02 -0700
Message-ID: <1376299202-30017-1-git-send-email-hykim@myri.com>
Cc: netdev@vger.kernel.org, Hyong-Youb Kim <hykim@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-43-81-194.west.biz.rr.com ([24.43.81.194]:1852 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752388Ab3HLLU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 07:20:56 -0400
Received: from myriam7.sw.myri.com (myriam7.sw.myri.com [172.31.130.79])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id r7CAuApK000625
	for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 03:56:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove Andrew Gallatin, as he is no longer with Myricom. Add
Hyong-Youb Kim as the new maintainer. Update the website URL.

Signed-off-by: Hyong-Youb Kim <hykim@myri.com>
---
 MAINTAINERS |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b57ecb1..0eb35c3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5576,9 +5576,9 @@ S:	Maintained
 F:	drivers/media/tuners/mxl5007t.*
 
 MYRICOM MYRI-10G 10GbE DRIVER (MYRI10GE)
-M:	Andrew Gallatin <gallatin@myri.com>
+M:	Hyong-Youb Kim <hykim@myri.com>
 L:	netdev@vger.kernel.org
-W:	http://www.myri.com/scs/download-Myri10GE.html
+W:	https://www.myricom.com/support/downloads/myri10ge.html
 S:	Supported
 F:	drivers/net/ethernet/myricom/myri10ge/
 
-- 
1.7.9
