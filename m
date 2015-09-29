From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Remove unneeded FEATURES_NEED_QUIESCE
 definition
Date: Mon, 28 Sep 2015 22:31:37 -0700 (PDT)
Message-ID: <20150928.223137.1393704643379436835.davem@davemloft.net>
References: <1443216692-29042-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbbI2Fbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:31:38 -0400
In-Reply-To: <1443216692-29042-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri, 25 Sep 2015 18:31:32 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> There is no need to have FEATURES_NEED_QUIESCE defined as we
> can simply use NETIF_F_RXCSUM instead as done in other parts
> of the driver.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied to net-next, thanks.
