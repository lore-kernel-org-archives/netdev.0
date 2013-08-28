From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 0/2] sh_eth Updates
Date: Wed, 28 Aug 2013 09:43:07 +0900
Message-ID: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Kouei Abe <kouei.abe.cp@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

please consider the following updates to the sh_eth driver
by Abe-san. They were developed during his testing of the
driver on the r8a7790/lager board.

Kouei Abe (2):
  sh_eth: Fix cache invalidation omission of receive buffer
  sh_eth: Enable Rx descriptor word 0 shift for r8a7790

 drivers/net/ethernet/renesas/sh_eth.c | 3 +++
 1 file changed, 3 insertions(+)

-- 
1.8.3.2

