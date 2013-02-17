From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/2] net: fec: Do a sanity check on the gpio number
Date: Sun, 17 Feb 2013 11:32:37 +0100
Message-ID: <201302171132.37529.marex@denx.de>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, shawn.guo@linaro.org,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60784 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab3BQKcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 05:32:42 -0500
In-Reply-To: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Fabio Estevam,

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Since commit 372e722ea4d (gpiolib: use descriptors internally) the
> following warning is seen on a mx28evk board:
[...]

I wonder if some dev_dbg() won't be a good idea here. Otherwise:

Acked-by: Marek Vasut <marex@denx.de>

Best regards,
Marek Vasut
