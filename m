From: David Miller <davem@davemloft.net>
Subject: Re: netpoll patches.
Date: Tue, 14 Nov 2006 20:43:40 -0800 (PST)
Message-ID: <20061114.204340.35016698.davem@davemloft.net>
References: <20061026192934.58c20e2a@localhost.localdomain>
	<20061113.170041.17866097.davem@davemloft.net>
	<20061114135500.5c6b17bc@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3791
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966635AbWKOEnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 23:43:39 -0500
To: shemminger@osdl.org
In-Reply-To: <20061114135500.5c6b17bc@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 14 Nov 2006 13:55:00 -0800

> The following changes since commit 5d1be92267c04a86232969710e32b6f99bb4ec12:
>   Peter Zijlstra:
>         [SCTP]: Cleanup of the sctp state table code.
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/netpoll-2.6.20
> 
> Stephen Hemminger:
>       netpoll: private skb pool (rev3)
>       netpoll info leak
>       netpoll per device txq
>       netpoll setup error handling
>       netpoll deferred transmit path
>       netpoll retry cleanup
>       netpoll queue cleanup
>       netpoll header cleanup

Pulled, thanks a lot Stephen.

I made a small follow-on patch to tidy up some coding style
things I noticed while re-reviewing this work.

Thanks again for taming the beast :)
