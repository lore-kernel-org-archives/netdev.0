From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 0/2] RDS: couple of fixes for 4.6
Date: Fri,  8 Apr 2016 15:26:38 -0700
Message-ID: <1460154400-14546-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches are also available at below git tree. 

git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.6/net-next/rds-fixes

Qing Huang (1):
  RDS: fix endianness for dp_ack_seq

Santosh Shilimkar (1):
  RDS: Fix the atomicity for congestion map update

 net/rds/cong.c  | 4 ++--
 net/rds/ib_cm.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
1.9.1
