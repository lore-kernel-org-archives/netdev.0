From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 2/2] net: fec: Improve logging
Date: Sun, 17 Feb 2013 11:33:03 +0100
Message-ID: <201302171133.03238.marex@denx.de>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com> <1361055207-22870-2-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, shawn.guo@linaro.org,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43273 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682Ab3BQKdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 05:33:04 -0500
In-Reply-To: <1361055207-22870-2-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Fabio Estevam,

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> In case the request of the GPIO reset fails it is interesting to log
> such error even if DEBUG is not enabled, so promote the message to dev_err.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Acked-by: Marek Vasut <marex@denx.de>

Best regards,
Marek Vasut
