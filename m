From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: remove sparse errors
Date: Mon, 05 Mar 2012 16:43:27 -0500 (EST)
Message-ID: <20120305.164327.1317747663425141163.davem@davemloft.net>
References: <CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
	<1330876610.2730.23.camel@edumazet-laptop>
	<1330959674.2474.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.co.il
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab2CEVng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 16:43:36 -0500
In-Reply-To: <1330959674.2474.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Mar 2012 07:01:14 -0800

> Fix new sparse errors introduced in commit 6221217199 (mlx4_en: dont
> change mac_header on xmit)
> 
> Reported-by: Or Gerlitz <or.gerlitz@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks.
