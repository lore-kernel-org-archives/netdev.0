From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Sat, 27 Feb 2010 23:53:09 +0800
Message-ID: <20100227155309.GA3344@gondor.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au> <E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au> <20100226164211.1a02a31b@nehalam> <20100227.032915.98669174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37058 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S968435Ab0B0PxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 10:53:14 -0500
Content-Disposition: inline
In-Reply-To: <20100227.032915.98669174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2010 at 03:29:15AM -0800, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 26 Feb 2010 16:42:11 -0800
> 
> > I like the functionality, but don't like users whacking on sysfs
> > directly. Could you send patches to integrate a user API into
> > bridge-utils; the utils are at: 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
> 
> Sounds reasonable to me.
> 
> Herbert, please do this after we've resolved the issues in your
> patch set and integrated it.

Will do.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
