From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 2/3][IPV4] Unify and cleanup calls to devinet_sysctl_register
Date: Sun, 2 Dec 2007 00:28:59 +1100
Message-ID: <20071201132859.GI15910@gondor.apana.org.au>
References: <475055F2.4090509@openvz.org> <20071201132000.GG15910@gondor.apana.org.au> <475160C1.9050808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3605 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751334AbXLAN3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:29:02 -0500
Content-Disposition: inline
In-Reply-To: <475160C1.9050808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 04:25:21PM +0300, Pavel Emelyanov wrote:
>
> > How about just giving it in_dev instead?
> 
> Hmm... Makes sense. Should I recreate the while set or
> just make the incremental one?

I've applied 1/3 for both cases so please just resend 2/3 and 3/3.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
