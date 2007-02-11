From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : restore multipath routing after rt_next changes
Date: Sat, 10 Feb 2007 16:57:17 -0800 (PST)
Message-ID: <20070210.165717.92584185.davem@davemloft.net>
References: <20070210023710.c7383c32.akpm@linux-foundation.org>
	<45CDA863.1060103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbXBKA5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 19:57:18 -0500
In-Reply-To: <45CDA863.1060103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 10 Feb 2007 12:11:31 +0100

> [PATCH] : NET : restore multipath routing after rt_next changes
> 
> I forgot to test build this part of the networking code... Sorry guys.
> This patch renames u.rt_next to u.dst.rt_next
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
