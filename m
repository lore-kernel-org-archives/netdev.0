From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] MAINTAINERS: net: update sfc maintainers
Date: Mon, 25 Apr 2016 17:42:12 +0100
Message-ID: <571E48E4.4050106@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:4029 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752389AbcDYQm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 12:42:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myself and Edward Cree as maintainers.
Remove Shradha Shah, who is on extended leave.

Cc: David S. Miller <davem@davemloft.net>
Cc: Edward Cree <ecree@solarflare.com>
Cc: Shradha Shah <sshah@solarflare.com>
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 MAINTAINERS | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8491336..17ad615 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10014,7 +10014,8 @@ F:	drivers/infiniband/hw/ocrdma/
 
 SFC NETWORK DRIVER
 M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
-M:	Shradha Shah <sshah@solarflare.com>
+M:	Edward Cree <ecree@solarflare.com>
+M:	Bert Kenward <bkenward@solarflare.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/sfc/
-- 
2.5.5
