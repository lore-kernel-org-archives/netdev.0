From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Ethernet over GRE and vlans
Date: Mon, 21 Feb 2011 16:38:54 +1100
Message-ID: <20110221053854.GA26462@gondor.apana.org.au>
References: <4D2F77A8.1010700@navigue.com> <4D43A296.4040906@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Thibault <jonathan@navigue.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35309 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab1BUFi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 00:38:57 -0500
Content-Disposition: inline
In-Reply-To: <4D43A296.4040906@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 29, 2011 at 12:16:06AM -0500, Jonathan Thibault wrote:
>
> Is it wrong on my part to expect such behaviour from gretap devices
> or is this simply not possible/implemented yet?

I don't see why this shouldn't work, so it might be a bug or
misconfiguration.  How did you setup gre1.1 and gre2.2?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
