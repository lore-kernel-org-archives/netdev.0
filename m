From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 8/9] cxgb4: add new PCI IDs
Date: Mon,  2 Aug 2010 16:19:23 -0700
Message-ID: <1280791164-14181-9-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
 <1280791164-14181-5-git-send-email-dm@chelsio.com>
 <1280791164-14181-6-git-send-email-dm@chelsio.com>
 <1280791164-14181-7-git-send-email-dm@chelsio.com>
 <1280791164-14181-8-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17197 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab0HBXT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:26 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJQdW025644
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:26 -0700
In-Reply-To: <1280791164-14181-8-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 5d5ea82..a4c4f52 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -175,6 +175,16 @@ enum {
 
 static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0xa000, 0),  /* PE10K */
+	CH_DEVICE(0x4001, 0),
+	CH_DEVICE(0x4002, 0),
+	CH_DEVICE(0x4003, 0),
+	CH_DEVICE(0x4004, 0),
+	CH_DEVICE(0x4005, 0),
+	CH_DEVICE(0x4006, 0),
+	CH_DEVICE(0x4007, 0),
+	CH_DEVICE(0x4008, 0),
+	CH_DEVICE(0x4009, 0),
+	CH_DEVICE(0x400a, 0),
 	{ 0, }
 };
 
-- 
1.5.4

