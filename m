From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 (resend) 3/3][IPV6] Use ctl paths to register addrconf sysctls
Date: Sun, 2 Dec 2007 01:00:05 +1100
Message-ID: <20071201140005.GM15910@gondor.apana.org.au>
References: <47505C7B.7070905@openvz.org> <20071201132422.GH15910@gondor.apana.org.au> <475165C1.9050307@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3866 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751733AbXLAOAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 09:00:08 -0500
Content-Disposition: inline
In-Reply-To: <475165C1.9050307@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 04:46:41PM +0300, Pavel Emelyanov wrote:
> This looks very much like the patch for ipv4's devinet.
> 
> This is also intended to help us with the net namespaces
> and saves the ipv6.ko size by ~320 bytes.
> 
> The difference from the first version is just the patch
> offsets, that changed due to changes in the patch #2.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Both applied.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
