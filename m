From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: 64 bit stats on all arches
Date: Thu, 08 Jul 2010 23:13:13 -0700 (PDT)
Message-ID: <20100708.231313.232763764.davem@davemloft.net>
References: <C27F8246C663564A84BB7AB3439772421B842BD250@IRVEXCHCCR01.corp.ad.broadcom.com>
	<1278598123.2651.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, mcarlson@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753046Ab0GIGM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:12:59 -0400
In-Reply-To: <1278598123.2651.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Jul 2010 16:08:43 +0200

> [PATCH net-next-2.6] bnx2: 64 bit stats on all arches
> 
> Now core network is able to handle 64 bit netdevice stats on 32 bit
> arches, we can provide them for bnx2, since hardware maintains some 64
> bit counters.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
