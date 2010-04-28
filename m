From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: Clean up left over prototype of
	igb_get_hw_dev_name()
Date: Wed, 28 Apr 2010 13:59:53 -0700
Message-ID: <20100428205949.30209.69599.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:50549
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754402Ab0D1VAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:00:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 096a526..735ede9 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -338,7 +338,6 @@ enum igb_boards {
 extern char igb_driver_name[];
 extern char igb_driver_version[];
 
-extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
 extern int igb_up(struct igb_adapter *);
 extern void igb_down(struct igb_adapter *);
 extern void igb_reinit_locked(struct igb_adapter *);

