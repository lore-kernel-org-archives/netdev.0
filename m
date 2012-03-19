From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH v2,0/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 14:23:52 -0700
Message-ID: <1332192233-32305-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

note: This patch is targeting 'net-next' tree.

The change log has been updated. Thanks to Eric Dumazet 
<eric.dumazet@gmail.com> and Stephen Hemminger <shemminger@vyatta.com>
for their suggestions.

Haiyang Zhang (1):
  net/hyperv: Fix the code handling tx busy

 drivers/net/hyperv/netvsc_drv.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

-- 
1.7.4.1
