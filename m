From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] fm10k: TRIVIAL remove unnecessary comma
Date: Tue, 22 Sep 2015 16:54:25 -0700
Message-ID: <1442966076-14359-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934900AbbIVXyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:40 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 5403d86..af09a1b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -129,8 +129,8 @@ static u16 fm10k_fifo_head_drop(struct fm10k_mbx_fifo *fifo)
  *  fm10k_fifo_drop_all - Drop all messages in FIFO
  *  @fifo: pointer to FIFO
  *
- *  This function resets the head pointer to drop all messages in the FIFO,
- *  and ensure the FIFO is empty.
+ *  This function resets the head pointer to drop all messages in the FIFO and
+ *  ensure the FIFO is empty.
  **/
 static void fm10k_fifo_drop_all(struct fm10k_mbx_fifo *fifo)
 {
-- 
2.4.3
