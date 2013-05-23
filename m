From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: Use DIV_ROUND_UP macro
Date: Thu, 23 May 2013 00:05:52 -0700 (PDT)
Message-ID: <20130523.000552.741229959575730714.davem@davemloft.net>
References: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org, kernel@pengutronix.de
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab3EWHFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:05:52 -0400
In-Reply-To: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Tue, 21 May 2013 12:44:26 -0300

> Use the standard DIV_ROUND_UP macro in order to provide better readability.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
