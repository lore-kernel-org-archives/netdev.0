From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] net: Add __dev_forward_skb
Date: Tue, 8 Apr 2014 15:15:18 +0800
Message-ID: <20140408071518.GA2694@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P1-0006vx-NF@gondolin.me.apana.org.au>
 <20140407114854.135e2e6c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60705 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253AbaDHHPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 03:15:25 -0400
Content-Disposition: inline
In-Reply-To: <20140407114854.135e2e6c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 07, 2014 at 11:48:54AM -0700, Stephen Hemminger wrote:
> On Mon, 07 Apr 2014 15:55:35 +0800
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > +}
> > +EXPORT_SYMBOL_GPL(__dev_forward_skb);
> > +
> 
> Don't export a symbol without a followup patch that uses it.

Sorry but I screwed the threading so the follow-up patch is in its
own thread.  But I assure you that this symbol is used in the
follow-up :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
