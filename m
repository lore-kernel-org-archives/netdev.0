From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv3] fragment locally-generated IPsec6 packets that need
	it
Date: Wed, 15 Dec 2010 14:39:10 +0800
Message-ID: <20101215063910.GA22666@gondor.apana.org.au>
References: <1292393929.5112.2.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41890 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab0LOGjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 01:39:16 -0500
Content-Disposition: inline
In-Reply-To: <1292393929.5112.2.camel@IBM-1B506CFC885>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 10:18:49PM -0800, David L Stevens wrote:
> This patch modifies IPsec6 to fragment IPv6 packets that are
> locally generated as needed.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks David!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
