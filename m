From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 5/5] sc92031: add a link to the datasheet
Date: Mon, 12 Jan 2009 21:21:51 -0200
Message-ID: <1231802511-14825-5-git-send-email-cesarb@cesarb.net>
References: <496BD04F.2050502@cesarb.net>
Cc: netdev@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:35379 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbZALX2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 18:28:33 -0500
In-Reply-To: <496BD04F.2050502@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 2a111f2..d26ee28 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -13,6 +13,9 @@
  *  Both are almost identical and seem to be based on pci-skeleton.c
  *
  *  Rewritten for 2.6 by Cesar Eduardo Barros
+ *
+ *  A datasheet for this chip can be found at
+ *  http://www.silan.com.cn/english/products/pdf/SC92031AY.pdf
  */
 
 /* Note about set_mac_address: I don't know how to change the hardware
-- 
1.6.1.dirty

