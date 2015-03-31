From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: smc91x: Remove an unused variable
Date: Tue, 31 Mar 2015 16:41:29 -0400 (EDT)
Message-ID: <20150331.164129.1888673211023785825.davem@davemloft.net>
References: <1427733818-11823-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbbCaUla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 16:41:30 -0400
In-Reply-To: <1427733818-11823-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon, 30 Mar 2015 13:43:38 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Commit cb6e0b3690f48dff ("net: smc91x: make use of 4th parameter to devm_gpiod_get_index")
> caused the following build warning:
> 
> drivers/net/ethernet/smsc/smc91x.c:2208:6: warning: unused variable 'res' [-Wunused-variable]
> 
> Remove the unused 'res' variable.
> 
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
