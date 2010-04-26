From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_sleep() helper
Date: Mon, 26 Apr 2010 11:17:06 -0700 (PDT)
Message-ID: <20100426.111706.39178292.davem@davemloft.net>
References: <1271804631.7895.519.camel@edumazet-laptop>
	<20100420.163919.82125824.davem@davemloft.net>
	<1272270006.2346.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57324
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750994Ab0DZSRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:17:01 -0400
In-Reply-To: <1272270006.2346.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Apr 2010 10:20:06 +0200

> Here is a followup to this patch, I missed three files in this
> conversion.
> 
> Thanks !
> 
> [PATCH net-next-2.6] net: use sk_sleep()
> 
> Commit aa395145 (net: sk_sleep() helper) missed three files in the
> conversion.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
