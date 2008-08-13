From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 19:58:03 +1000
Message-ID: <20080813095803.GA25372@gondor.apana.org.au>
References: <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local> <20080813.022549.203848195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59673 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751809AbYHMJ6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:58:10 -0400
Content-Disposition: inline
In-Reply-To: <20080813.022549.203848195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 02:25:49AM -0700, David Miller wrote:
> 
> pkt_sched: Fix queue quiescence testing in dev_deactivate().

Looks good to me.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
