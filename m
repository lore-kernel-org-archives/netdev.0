From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with ipcomp
Date: Sat, 9 Feb 2008 05:31:57 +1100
Message-ID: <20080208183157.GA18795@gondor.apana.org.au>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local> <20080207154437.GA7237@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20CE@exch.facton.local> <20080208085836.GC14650@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20D4@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45003 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754953AbYBHScA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 13:32:00 -0500
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F20D4@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 08, 2008 at 11:45:33AM +0100, Beschorner Daniel wrote:
> > No I meant the exact output of ip x p and ip x s.
> 
> I know, but as I end up every time with a tainted kernel on our
> production server I didn't turn ipcomp on, but now I got it.

Hmm, that's pretty much what I've got (but I'm on 32-bit still).

Does every packet from A trigger the crash?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
