From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip: add loose reverse path filtering
Date: Sun, 22 Feb 2009 16:34:36 +0800
Message-ID: <20090222083436.GA1975@gondor.apana.org.au>
References: <20090220102536.2d39ddb9@extreme> <20090221130907.GA28765@gondor.apana.org.au> <20090221.235601.92406212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, hawk@diku.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41294 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751283AbZBVIeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:34:46 -0500
Content-Disposition: inline
In-Reply-To: <20090221.235601.92406212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2009 at 11:56:01PM -0800, David Miller wrote:
>
> > Rather than extending the rp_filter stuff any further, I'd prefer
> > to see this replaced with netfilter plugin.
> 
> Normally I would agree, but in this case the cost is exactly
> zero for the added flexibility.

Ah I thought there was another patch coming :) But obviously as
this is all that's needed for it sure it looks good to me too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
