From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2 net-next] net: fec: correct fix method about
 miss init spinlock
Date: Thu, 07 Feb 2013 23:36:59 -0500 (EST)
Message-ID: <20130207.233659.807881034629000930.davem@davemloft.net>
References: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756979Ab3BHEhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:37:00 -0500
In-Reply-To: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 7 Feb 2013 08:59:58 +0800

> Old method will cause init spinlock twice.
> New method will avoid init spinlock twice and fix miss init spinlock
> at fec_restart.
 ...
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
