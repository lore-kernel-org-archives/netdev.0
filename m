From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4 00/14] l2tp: Introduce L2TPv3 support
Date: Sun, 04 Apr 2010 01:02:59 -0700 (PDT)
Message-ID: <20100404.010259.161188935.davem@davemloft.net>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
	<20100403.142522.01040744.davem@davemloft.net>
	<1270367668.1971.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60233
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751537Ab0DDIC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 04:02:57 -0400
In-Reply-To: <1270367668.1971.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Apr 2010 09:54:28 +0200

> [PATCH net-next-2.6] l2tp: unmanaged L2TPv3 tunnels fixes
> 
> Followup to commit 789a4a2c 
> (l2tp: Add support for static unmanaged L2TPv3 tunnels)
> 
> One missing init in l2tp_tunnel_sock_create() could access random kernel
> memory, and a bit field should be unsigned.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
