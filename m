From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 7/9] e1000: remove email reference
Date: Fri, 11 Jul 2008 15:17:33 -0700
Message-ID: <20080711221733.3255.65618.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51567 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847AbYGKWRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:34 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The email linux-nics@intel.com is no longer available, remove all
references.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d1d4d00..28d14ae 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -866,7 +866,7 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 	printk(KERN_ERR "to enable this network device.\n");
 	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
 	       "to your hardware vendor\n");
-	printk(KERN_ERR "or Intel Customer Support: linux-nics@intel.com\n");
+	printk(KERN_ERR "or Intel Customer Support.\n");
 	printk(KERN_ERR "/*********************/\n");
 
 	kfree(data);

