From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: use this_cpu_ptr() in
 vlan_skb_recv()
Date: Mon, 27 Sep 2010 21:51:10 -0700 (PDT)
Message-ID: <20100927.215110.59690889.davem@davemloft.net>
References: <1285577229.10965.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702Ab0I1Euu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:50:50 -0400
In-Reply-To: <1285577229.10965.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Sep 2010 10:47:09 +0200

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
