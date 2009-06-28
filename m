From: Joe Perches <joe@perches.com>
Subject: [PATCH 28/62] drivers/net/bnx2x_link.c: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:33 -0700
Message-ID: <4d93663ae786b672e1723b5e24cef0c05461f527.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1124 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351AbZF1Q1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:43 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ed648ac..f5f45c6 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2390,7 +2390,7 @@ static u8 bnx2x_read_sfp_module_eeprom(struct link_params *params, u16 addr,
 			      MDIO_PMA_REG_8726_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_8726_TWO_WIRE_STATUS_IDLE)
-			return 0;;
+			return 0;
 		msleep(1);
 	}
 	return -EINVAL;
-- 
1.6.3.1.10.g659a0.dirty

