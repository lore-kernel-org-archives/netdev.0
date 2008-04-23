From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 23 Apr 2008 15:30:03 +0800
Message-ID: <20080423073003.GB29767@gondor.apana.org.au>
References: <200803261115.26157.joakim.koskela@hiit.fi> <200804221512.40780.joakim.koskela@hiit.fi> <20080422131358.GA20418@gondor.apana.org.au> <200804231013.38390.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38830 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751114AbYDWHaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 03:30:07 -0400
Content-Disposition: inline
In-Reply-To: <200804231013.38390.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 10:13:38AM +0300, Joakim Koskela wrote:
>
> Sorry, I know really should. I'll try to get back on this asap with some more 
> details. But in a nutshell - I get crashes on 4-6 (inner-outer), and although 
> 6-4 gets packets on the wire, they're somehow wrong. Hm, don't actually think 
> there's anything wrong with 6-6 though, I'll have to recheck that.. 

OK I'll try to get my test environment back up to have a look.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
