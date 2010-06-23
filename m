From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about xfrm by MARK feature
Date: Thu, 24 Jun 2010 08:16:33 +1000
Message-ID: <20100623221633.GA9237@gondor.apana.org.au>
References: <201006231803.17261.lists@egidy.de> <4C223310.6090006@trash.net> <201006240013.58261.lists@egidy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	timo.teras@iki.fi, netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60841 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab0FWWQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 18:16:47 -0400
Content-Disposition: inline
In-Reply-To: <201006240013.58261.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 12:13:57AM +0200, Gerd v. Egidy wrote:
> 
> That would work for endpoints with fixed ips. But as soon as the endpoint has a 
> dynamic ip, I'd have to change the iptables depending on the vpns currently 
> connected. This is something I want to avoid in any case. 

That's what reqids are for.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
