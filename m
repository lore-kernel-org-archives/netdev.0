From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: print protocol in host byte order
Date: Wed, 21 Apr 2010 22:57:32 -0700 (PDT)
Message-ID: <20100421.225732.244730348.davem@davemloft.net>
References: <1271833567.3627.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44733
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752741Ab0DVF51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:57:27 -0400
In-Reply-To: <1271833567.3627.12.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 21 Apr 2010 09:06:07 +0200

> Eric's recent patch added __force, but this
> place would seem to require actually doing
> a byte order conversion so the printk is
> consistent across architectures.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied to net-next-2.6, thanks a lot Johannes.
