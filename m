From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: use module_platform_driver
Date: Tue, 24 Jan 2012 23:00:28 -0500 (EST)
Message-ID: <20120124.230028.2047491768518849458.davem@davemloft.net>
References: <1327373090-22004-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab2AYEBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 23:01:41 -0500
In-Reply-To: <1327373090-22004-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 24 Jan 2012 00:44:50 -0200

> Using module_platform_driver can make the code smaller.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
