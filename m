From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with ipcomp
Date: Fri, 8 Feb 2008 02:44:37 +1100
Message-ID: <20080207154437.GA7237@gondor.apana.org.au>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38812 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755070AbYBGPom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 10:44:42 -0500
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 09:55:03PM +0100, Beschorner Daniel wrote:
>
> A is the oopsing 2.6.24, B is 2.6.23.
> I didn't change anything in the scenario recently, till 2.6.23 all
> worked fine.

OK, so are you now able to reproduce this crash without waiting
for hours? That would be really helpful in tracking it down.

Could you show me the exact policies/SAs of the tunnel involved
in the crash?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
