From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RESEND PATCH net-next 0/4] net: several cleanups
Date: Thu, 28 Nov 2013 09:31:29 +0800
Message-ID: <1385602293-24024-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Per David's request, it's time to resend them now.

Zhi Yong Wu (4):
  vhost: remove the dead branch
  vhost: adjust vhost_dev_init() to be void
  macvtap: remove the dead branch
  macvtap: adjust macvtap_skb_to_vnet_hdr() to be void

 drivers/net/macvtap.c |    8 ++------
 drivers/vhost/net.c   |    9 ++-------
 drivers/vhost/scsi.c  |    7 +------
 drivers/vhost/test.c  |    8 +-------
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 6 files changed, 8 insertions(+), 30 deletions(-)

-- 
1.7.6.5
