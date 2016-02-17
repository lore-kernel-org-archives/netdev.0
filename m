From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/2] ixgbe: fix dates on header of ixgbe_model.h
Date: Wed, 17 Feb 2016 14:35:23 -0800
Message-ID: <20160217223523.9858.45576.stgit@john-Precision-Tower-5810>
References: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: john.fastabend@gmail.com, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36214 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423442AbcBQWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 17:35:38 -0500
Received: by mail-pf0-f180.google.com with SMTP id e127so18913862pfe.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 14:35:38 -0800 (PST)
In-Reply-To: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 9d35cf062e05 ("net: ixgbe: add minimal parser details for ixgbe")
Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
index 62ea2e7..ce48872 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel 10 Gigabit PCI Express Linux drive
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
