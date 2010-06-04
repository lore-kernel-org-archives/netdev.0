From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: RCU changes in __mkroute_input()
Date: Thu, 03 Jun 2010 20:05:01 -0700 (PDT)
Message-ID: <20100603.200501.112615902.davem@davemloft.net>
References: <1275574401.2456.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932346Ab0FDDEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:04:51 -0400
In-Reply-To: <1275574401.2456.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 16:13:21 +0200

> Avoid two atomic ops on output device refcount
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
