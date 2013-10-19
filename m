From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: Implement GSO/TSO support for IPIP
Date: Sat, 19 Oct 2013 19:37:41 -0400 (EDT)
Message-ID: <20131019.193741.1765666924789441714.davem@davemloft.net>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
	<1382209158.3284.47.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, hkchu@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3JSXhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 19:37:43 -0400
In-Reply-To: <1382209158.3284.47.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Oct 2013 11:59:18 -0700

> On Sat, 2013-10-19 at 11:42 -0700, Eric Dumazet wrote:
>> This patch serie implements GSO/TSO support for IPIP
>> 
>> David, please note it applies after "ipv4: gso: send_check() & segment() cleanups"
>> ( http://patchwork.ozlabs.org/patch/284714/ )
> 
> Oh well, I meant to say the above patch was _included_ in this patch
> set.

I understood what you meant, especially because I just applied the patch
in question :-)

This looks fantastic, all applied, thanks!
