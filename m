From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: bcmgenet: Use devm_ioremap_resource()
Date: Mon, 24 Feb 2014 19:30:16 -0500 (EST)
Message-ID: <20140224.193016.1436821148718736547.davem@davemloft.net>
References: <1393213644-11081-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaBYAaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:30:18 -0500
In-Reply-To: <1393213644-11081-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon, 24 Feb 2014 00:47:24 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> According to Documentation/driver-model/devres.txt, devm_request_and_ioremap()
> is deprecated, so use devm_ioremap_resource() instead.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
