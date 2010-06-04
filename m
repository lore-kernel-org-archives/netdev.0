From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: use correct net ns in cookie_v4_check()
Date: Fri, 04 Jun 2010 15:57:24 -0700 (PDT)
Message-ID: <20100604.155724.48520332.davem@davemloft.net>
References: <1275579947.2456.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757121Ab0FDW5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:57:14 -0400
In-Reply-To: <1275579947.2456.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 17:45:47 +0200

> [PATCH] tcp: use correct net ns in cookie_v4_check()
> 
> Its better to make a route lookup in appropriate namespace.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric!
