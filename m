From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V5 8/8] MAINTAINERS: add maintainer for Samsung sxgbe driver
Date: Tue, 18 Mar 2014 11:19:25 -0700
Message-ID: <002201cf42d6$98aa5cd0$c9ff1670$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:35052 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757405AbaCRSTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:19:31 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 MAINTAINERS |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index b7befe7..aeb81f2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7536,6 +7536,15 @@ S:	Supported
 L:	linux-samsung-soc@vger.kernel.org (moderated for non-subscribers)
 F:	drivers/clk/samsung/
 
+SAMSUNG SXGBE DRIVERS
+M:	Byungho An <bh74.an@samsung.com>
+M:	Girish K S <ks.giri@samsung.com>
+M:	Siva Reddy Kallam <siva.kallam@samsung.com>
+M:	Vipul Pandya <vipul.pandya@samsung.com>
+S:	Supported
+L:	netdev@vger.kernel.org
+F:	drivers/net/ethernet/samsung/sxgbe/
+
 SERIAL DRIVERS
 M:	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
 L:	linux-serial@vger.kernel.org
-- 
1.7.10.4
