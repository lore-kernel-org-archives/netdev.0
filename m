From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Wed, 02 Oct 2013 23:44:17 -0400 (EDT)
Message-ID: <20131002.234417.149459627679517962.davem@davemloft.net>
References: <1380760114.2081.81.camel@joe-AO722>
	<1380771110.2081.89.camel@joe-AO722>
	<1380771551.2081.93.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo@qca.qualcomm.com, julia.lawall@lip6.fr,
	mcgrof@do-not-panic.com, netdev@vger.kernel.org,
	ath10k@lists.infradead.org, linville@tuxdriver.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398Ab3JCDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 23:44:19 -0400
In-Reply-To: <1380771551.2081.93.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 02 Oct 2013 20:39:11 -0700

> Use the appropriate define instead of 6.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Noticed-by: Julia Lawall <julia.lawall@lip6.fr> via spatch script

Applied, thanks Joe.
