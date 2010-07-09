From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 V2] tg3: 64 bit stats on all arches
Date: Thu, 08 Jul 2010 23:14:00 -0700 (PDT)
Message-ID: <20100708.231400.229729670.davem@davemloft.net>
References: <1278571464.2543.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752459Ab0GIGNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:13:45 -0400
In-Reply-To: <1278571464.2543.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Jul 2010 08:44:24 +0200

> Now core network is able to handle 64 bit netdevice stats on 32 bit
> arches, we can provide them for tg3, since hardware maintains 64 bit
> counters.
> 
> I'll provide bnx2 and bnx2x patches as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
