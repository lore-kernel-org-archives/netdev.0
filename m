From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: sr9800: Use '%zu' to print size_t format
Date: Fri, 14 Feb 2014 13:59:42 -0500 (EST)
Message-ID: <20140214.135942.182955210605138238.davem@davemloft.net>
References: <1392384335-19707-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liujunliang_ljl@163.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbaBNS7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 13:59:44 -0500
In-Reply-To: <1392384335-19707-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Fri, 14 Feb 2014 11:25:35 -0200

> Fix the following build warning on ARM:
> 
> drivers/net/usb/sr9800.c:826:2: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'size_t' [-Wformat]
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Already fixed in the 'net' tree, thanks.
