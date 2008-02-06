From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with ipcomp
Date: Thu, 7 Feb 2008 04:07:17 +1100
Message-ID: <20080206170717.GA20308@gondor.apana.org.au>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35174 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756004AbYBFRHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 12:07:19 -0500
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 03:43:25PM +0100, Beschorner Daniel wrote:
> 
> Net_A - GW_A --- GW_B - Net_B
> 
> The Net_A - Net_B ESP/AES/IPComp tunnel works fine, the tunnel between
> Net_B and the external IP address of GW_A triggers the oops in GW_A.

That's interesting.  So which one out of A and B is running 2.6.24?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
