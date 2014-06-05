From: Amos Kong <akong@redhat.com>
Subject: [PATCH 0/2] trivial cleanup
Date: Thu,  5 Jun 2014 11:01:20 +0800
Message-ID: <1401937282-18345-1-git-send-email-akong@redhat.com>
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, davem@davemloft.net,
	schwab@linux-m68k.org
To: linux-m68k@vger.kernel.org
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found the RAM size in comments isn't correct,
fix it.

Amos Kong (2):
  mvme147: fix ram size in comment
  hplance: fix ram size in comment

 drivers/net/ethernet/amd/hplance.c | 4 ++--
 drivers/net/ethernet/amd/mvme147.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

-- 
1.9.3
