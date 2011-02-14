From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 3/9] jme: Fix bit typo of JMC250A2 workaround
Date: Mon, 14 Feb 2011 12:27:36 +0800
Message-ID: <1297657662-30289-3-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48721 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145Ab1BNE2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:16 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index c3764fc..dc4af57 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -1000,8 +1000,8 @@ enum jme_gpreg1_masks {
 };
 
 enum jme_gpreg1_vals {
-	GPREG1_RSSPATCH		= 0x00000040,
-	GPREG1_HALFMODEPATCH	= 0x00000020,
+	GPREG1_HALFMODEPATCH	= 0x00000040,
+	GPREG1_RSSPATCH		= 0x00000020,
 
 	GPREG1_INTDLYUNIT_16NS	= 0x00000000,
 	GPREG1_INTDLYUNIT_256NS	= 0x00000008,
-- 
1.7.2.2

