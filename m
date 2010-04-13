From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers: net: last_rx elimination
Date: Tue, 13 Apr 2010 03:33:46 -0700 (PDT)
Message-ID: <20100413.033346.221831757.davem@davemloft.net>
References: <1270975694.2078.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520Ab0DMKdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:33:42 -0400
In-Reply-To: <1270975694.2078.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Apr 2010 10:48:14 +0200

> Network drivers do not have to update last_rx, unless they need it for
> their private use.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for taking care of this Eric.
