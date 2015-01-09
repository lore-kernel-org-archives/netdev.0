From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] Revert "ARM: dts: imx6qdl: enable FEC
 magic-packet feature"
Date: Thu, 08 Jan 2015 20:05:46 -0800 (PST)
Message-ID: <20150108.200546.269142338503098096.davem@davemloft.net>
References: <1420634393-30027-1-git-send-email-festevam@gmail.com>
	<1420634393-30027-2-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, fugang.duan@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbbAIEAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 23:00:04 -0500
In-Reply-To: <1420634393-30027-2-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed,  7 Jan 2015 10:39:53 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> As 456062b3ec6f ("ARM: imx: add FEC sleep mode callback function") has been
> reverted, also revert the dts part.
> 
> This reverts commit 07b4d2dda0c00f56248 ("ARM: dts: imx6qdl: enable FEC 
> magic-packet feature").
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
