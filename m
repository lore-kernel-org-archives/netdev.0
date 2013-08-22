From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-08-22
Date: Thu, 22 Aug 2013 16:05:34 -0700 (PDT)
Message-ID: <20130822.160534.1609765522942458242.davem@davemloft.net>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3HVXFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 19:05:38 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Aug 2013 13:12:04 +0200

> 1) Some constifications, from Mathias Krause.
> 
> 2) Catch bugs if a hold timer is still active when xfrm_policy_destroy()
>    is called, from Fan Du.
> 
> 3) Remove a redundant address family checking, from Fan Du.
> 
> 4) Make xfrm_state timer monotonic to be independent of system clock changes,
>    from Fan Du.
> 
> 5) Remove an outdated comment on returning -EREMOTE in the xfrm_lookup(),
>    from Rami Rosen.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
