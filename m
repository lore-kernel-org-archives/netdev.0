From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-10-18
Date: Fri, 18 Oct 2013 13:52:10 -0400 (EDT)
Message-ID: <20131018.135210.2168457289330865474.davem@davemloft.net>
References: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756409Ab3JRRwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:52:11 -0400
In-Reply-To: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 18 Oct 2013 10:42:06 +0200

> 1) Don't use a wildcard SA if a more precise one is in acquire state,
>    from Fan Du.
> 
> 2) Simplify the SA lookup when using wildcard source. We need to check
>    only the destination in this case, from Fan Du.
> 
> 3) Add a receive path hook for IPsec virtual tunnel interfaces
>    to xfrm6_mode_tunnel.
> 
> 4) Add support for IPsec virtual tunnel interfaces to ipv6.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
