From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 16:55:53 +0800
Message-ID: <20080805085553.GA21094@gondor.apana.org.au>
References: <200808041619.42562.joakim.koskela@hiit.fi> <200808051013.19873.joakim.koskela@hiit.fi> <20080805072249.GA20340@gondor.apana.org.au> <200808051136.47222.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57703 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760028AbYHEJZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 05:25:58 -0400
Content-Disposition: inline
In-Reply-To: <200808051136.47222.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 11:36:46AM +0300, Joakim Koskela wrote:
>
> Sure, thanks. We should probably do the same in ipv4's output as well (only 
> add the IPV4_BEET_PHMAXLEN if the inner family != ipv6).

Good point.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
