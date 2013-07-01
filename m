From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next v3 0/3] sh_eth: Add support for r8a7790 SoC
Date: Mon,  1 Jul 2013 13:24:52 +0900
Message-ID: <1372652695-16606-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52916 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3GAEZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 00:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series enhances the sh_eth driver for use with the r8a7790 SoC.

Simon Horman (3):
  sh_eth: add support for gpio reset
  sh_eth: add support RMIIMODE register
  sh_eth: Add support for r8a7790 SoC

 drivers/net/ethernet/renesas/Kconfig  |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c | 29 +++++++++++++++++++++++++++++
 drivers/net/ethernet/renesas/sh_eth.h |  2 ++
 include/linux/sh_eth.h                |  3 +++
 4 files changed, 35 insertions(+), 1 deletion(-)

-- 
1.8.2.1
