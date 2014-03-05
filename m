From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 7/7] MAINTAINERS: add maintainer for Samsung xgmac driver
Date: Wed, 05 Mar 2014 20:28:31 +0900
Message-ID: <008101cf3866$09d66960$1d833c20$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:23490 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbaCEL2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:28:44 -0500
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 MAINTAINERS |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index c6d0e93..10cb617 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7526,6 +7526,15 @@ S:	Supported
 L:	linux-samsung-soc@vger.kernel.org (moderated for non-subscribers)
 F:	drivers/clk/samsung/
 
+SAMSUNG XGMAC DRIVERS
+M:	Byungho An <bh74.an@samsung.com>
+M:	Girish K S <ks.giri@samsung.com>
+M:	Siva Reddy Kallam <siva.kallam@samsung.com>
+M:	Vipul Pandya <vipul.pandya@samsung.com>
+S:	Supported
+L:	netdev@vger.kernel.org
+F:	drivers/net/ethernet/samsung/
+
 SERIAL DRIVERS
 M:	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
 L:	linux-serial@vger.kernel.org
-- 
1.7.10.4
