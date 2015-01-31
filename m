From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/6] rhashtable: Use a single bucket lock for sibling
 buckets
Date: Sat, 31 Jan 2015 20:38:12 +1100
Message-ID: <20150131093812.GA29240@gondor.apana.org.au>
References: <14d537500868b4ff0396168cf9d5db95d327c128.1422576760.git.tgraf@suug.ch>
 <20150131043436.GA27564@gondor.apana.org.au>
 <20150131084127.GA13841@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ying.xue@windriver.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40531 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbAaJiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 04:38:21 -0500
Content-Disposition: inline
In-Reply-To: <20150131084127.GA13841@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2015 at 08:41:27AM +0000, Thomas Graf wrote:
> On 01/31/15 at 03:34pm, Herbert Xu wrote:
> > Thomas, could you please hold off on these changes? They totally
> > conflict with my rehash work, which is going to render these changes
> > moot anyway since it'll completely change how expansion/shrinking
> > works.
> 
> Can you share that work?

I will post it when it's ready.  But if you keep moving the goal
posts then I'll never get there.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
