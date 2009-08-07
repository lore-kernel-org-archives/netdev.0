From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] mlx4_en: Not using Shared Receive
 Queues
Date: Thu, 06 Aug 2009 19:28:36 -0700 (PDT)
Message-ID: <20090806.192836.06072694.davem@davemloft.net>
References: <4A631A81.5070606@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756471AbZHGC21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 22:28:27 -0400
In-Reply-To: <4A631A81.5070606@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 19 Jul 2009 16:07:13 +0300

> We use 1:1 mapping between QPs and SRQs on receive side,
> so additional indirection level not required. Allocated the receive
> buffers for the RSS QPs.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
