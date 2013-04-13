From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 16:52:06 -0400 (EDT)
Message-ID: <20130413.165206.486182674283306285.davem@davemloft.net>
References: <1365873936-9521-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org, joe@perches.com,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab3DMUwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 16:52:08 -0400
In-Reply-To: <1365873936-9521-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sat, 13 Apr 2013 14:25:36 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Currently when booting a mx6 device we get the following on boot:
> 
> registered PHC device on eth%d
> 
> Fix it by printing the network device name only after it gets registered, so
> that the following can be read now:
> 
> fec 2188000.ethernet eth0: registered PHC device 0
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
