From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2015-08-17
Date: Mon, 17 Aug 2015 14:05:31 -0700 (PDT)
Message-ID: <20150817.140531.2284471271781345011.davem@davemloft.net>
References: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbbHQVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:05:32 -0400
In-Reply-To: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 17 Aug 2015 21:58:17 +0200

> 1) Fix IPv6 ECN decapsulation for IPsec interfamily tunnels.
>    From Thomas Egerer.
> 
> 2) Use kmemdup instead of duplicating it in xfrm_dump_sa().
>    From Andrzej Hajda.
> 
> 3) Pass oif to the xfrm lookups so that it gets set on the flow
>    and the resolver routines can match based on oif.
>    From David Ahern.
> 
> 4) Add documentation for the new xfrm garbage collector threshold.
>    From Alexander Duyck.
> 
> Please pull or let me know if there are problems.

Pulled, thank you Steffen.
