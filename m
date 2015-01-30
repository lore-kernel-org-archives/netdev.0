From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Fri, 30 Jan 2015 16:58:59 +1100
Message-ID: <20150130055859.GA17149@gondor.apana.org.au>
References: <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
 <20150127112304.GA4548@gondor.apana.org.au>
 <20150127130950.GA3950@acer.localdomain>
 <20150127203657.GA9061@gondor.apana.org.au>
 <20150128190715.GA4764@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47719 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbbA3F7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 00:59:45 -0500
Content-Disposition: inline
In-Reply-To: <20150128190715.GA4764@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 07:07:16PM +0000, Patrick McHardy wrote:
> On 28.01, Herbert Xu wrote:
> > On Tue, Jan 27, 2015 at 01:09:50PM +0000, Patrick McHardy wrote:
> > >
> > > Actually I have a patchset queued that adds runtime additions and
> > > removals, both active and timeout based. So netfilter won't have
> > > pure synchronous behaviour anymore.
> > 
> > Can you show us the patchset?
> 
> Sure, will send it over tomorrow.

So how are you handling the locking in these cases?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
