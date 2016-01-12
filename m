From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix typo in netdev_intersect_features
Date: Mon, 11 Jan 2016 23:30:09 -0500 (EST)
Message-ID: <20160111.233009.2252363283813047899.davem@davemloft.net>
References: <1452536350-432426-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760963AbcALEaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 23:30:12 -0500
In-Reply-To: <1452536350-432426-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 11 Jan 2016 10:19:10 -0800

> Obviously need to 'or in NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.
> 
> Fixes: c8cd0989bd151f ("net: Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM")
> Reported-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks Tom.
