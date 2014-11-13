From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 0/3] sh_eth: Remove redundant alignment adjustment
Date: Thu, 13 Nov 2014 16:04:58 +0900
Message-ID: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is based on net tree.

Mitsuhiro Kimura (3):
  sh_eth: Remove redundant alignment adjustment
  sh_eth: Fix skb alloc size and alignment adjust rule.
  sh_eth: Fix dma mapping issue

 drivers/net/ethernet/renesas/sh_eth.c | 65 +++++++++++++++++++++--------------
 drivers/net/ethernet/renesas/sh_eth.h |  2 ++
 2 files changed, 41 insertions(+), 26 deletions(-)

-- 
1.9.1

