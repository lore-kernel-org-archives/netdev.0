From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ethoc: get rid of ethoc_stats()
Date: Tue, 24 Aug 2010 12:23:07 -0700 (PDT)
Message-ID: <20100824.122307.112617061.davem@davemloft.net>
References: <1282663331.2477.255.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069Ab0HXTWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:22:49 -0400
In-Reply-To: <1282663331.2477.255.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Aug 2010 17:22:11 +0200

> drivers can avoid implementing ndo_get_stats method if using netdevice
> stats structure.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
