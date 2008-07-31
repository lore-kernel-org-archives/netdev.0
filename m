From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] qla3xxx: cleanup: Remove some unused defined constants in the header file.
Date: Thu, 31 Jul 2008 13:46:06 -0700
Message-ID: <1217537168428-git-send-email-ron.mercer@qlogic.com>
References: <20080731204514.GA5457@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23911 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690AbYGaUqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 16:46:10 -0400
In-Reply-To: <20080731204514.GA5457@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.h |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 58a086f..e0655f9 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -14,19 +14,11 @@
 
 #define OPCODE_OB_MAC_IOCB_FN0          0x01
 #define OPCODE_OB_MAC_IOCB_FN2          0x21
-#define OPCODE_OB_TCP_IOCB_FN0          0x03
-#define OPCODE_OB_TCP_IOCB_FN2          0x23
-#define OPCODE_UPDATE_NCB_IOCB_FN0      0x00
-#define OPCODE_UPDATE_NCB_IOCB_FN2      0x20
 
-#define OPCODE_UPDATE_NCB_IOCB      0xF0
 #define OPCODE_IB_MAC_IOCB          0xF9
 #define OPCODE_IB_3032_MAC_IOCB     0x09
 #define OPCODE_IB_IP_IOCB           0xFA
 #define OPCODE_IB_3032_IP_IOCB      0x0A
-#define OPCODE_IB_TCP_IOCB          0xFB
-#define OPCODE_DUMP_PROTO_IOCB      0xFE
-#define OPCODE_BUFFER_ALERT_IOCB    0xFB
 
 #define OPCODE_FUNC_ID_MASK                 0x30
 #define OUTBOUND_MAC_IOCB                   0x01	/* plus function bits */
-- 
1.5.0.rc4.16.g9e258

