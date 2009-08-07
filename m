From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] mlx4_en: Adaptive moderation policy
 change
Date: Thu, 06 Aug 2009 19:28:25 -0700 (PDT)
Message-ID: <20090806.192825.129433188.davem@davemloft.net>
References: <4A631A64.50804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752166AbZHGC2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 22:28:16 -0400
In-Reply-To: <4A631A64.50804@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 19 Jul 2009 16:06:44 +0300

> If the net device is identified as "sender" (number of sent packets
> is higher then the number of received packets and the incoming packets are
> small), set the moderation time to its low limit.
> We do it because the incoming packets are acks, and we don't want to delay them
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
