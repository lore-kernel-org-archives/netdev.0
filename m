From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip, ipv6: handle gso skbs in forwarding path
Date: Fri, 21 Feb 2014 08:57:34 +0100
Message-ID: <20140221075734.GC7119@breakpoint.cc>
References: <20140220.230604.1339438303517965435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40054 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750884AbaBUH5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 02:57:36 -0500
Content-Disposition: inline
In-Reply-To: <20140220.230604.1339438303517965435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> Florian, could you please do a -stable backport of this patch
> series?
> 
> I gave it a try and got stuck. :)

sure, I'll get to it later today.
