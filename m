From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: tidyup compile warning
Date: Mon, 27 Jun 2011 21:03:38 -0700 (PDT)
Message-ID: <20110627.210338.1356810919488149764.davem@davemloft.net>
References: <87pqm40yx3.wl%kuninori.morimoto.gx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: kuninori.morimoto.gx@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756443Ab1F1EDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:03:43 -0400
In-Reply-To: <87pqm40yx3.wl%kuninori.morimoto.gx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Date: Thu, 23 Jun 2011 19:02:38 -0700 (PDT)

> This patch tidyup below warning
> 
> ${LINUX}/drivers/net/sh_eth.c:1773: warning:
> 'mdp' may be used uninitialized in this function
> 
> Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Kuninori Morimoto <morimoto.kuninori@renesas.com>

Applied, thanks.
