From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: enable pause frame to
 improve rx prefomance for 1G network
Date: Fri, 18 Jan 2013 14:16:26 -0500 (EST)
Message-ID: <20130118.141626.1543157230023121224.davem@davemloft.net>
References: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:16:28 -0500
In-Reply-To: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 17 Jan 2013 10:55:58 +0800

> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
> There will be many packages lost because FIFO over run.
> 
> This patch enable pause frame flow control.
 ...
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied.
