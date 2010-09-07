From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mlx4_en: Consider napi_get_frags() failure.
Date: Mon, 06 Sep 2010 18:39:22 -0700 (PDT)
Message-ID: <20100906.183922.98874231.davem@davemloft.net>
References: <4C84A43B.5010605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755532Ab0IGBjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:39:05 -0400
In-Reply-To: <4C84A43B.5010605@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 6 Sep 2010 11:20:11 +0300

> 
> If failed to get skb frags using napi_get_frags(),
> the packet is dropped.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
