From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: Change clock warning message to debug level
Date: Thu, 20 Mar 2014 16:17:38 -0400 (EDT)
Message-ID: <20140320.161738.165135937196577853.davem@davemloft.net>
References: <1395238926-16126-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758197AbaCTURk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:17:40 -0400
In-Reply-To: <1395238926-16126-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Wed, 19 Mar 2014 11:22:06 -0300

> Since passing the clock is not mandatory, change the warning message to debug, 
> so that we avoid getting the following clock failure message on every boot:
> 
> smsc911x: Driver version 2008-10-21                                             
> smsc911x smsc911x (unregistered net_device): couldn't get clock -2              
> libphy: smsc911x-mdio: probed                                                   
>   
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied to net-next, thanks.
