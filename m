From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4] fragment locally generated tunnel-mode IPSec6
	packets as needed
Date: Sat, 18 Dec 2010 10:16:06 +0800
Message-ID: <20101218021606.GA26888@gondor.apana.org.au>
References: <1292622162.1700.3.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33551 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756873Ab0LRCQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 21:16:15 -0500
Content-Disposition: inline
In-Reply-To: <1292622162.1700.3.camel@IBM-1B506CFC885>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 01:42:42PM -0800, David L Stevens wrote:
> This patch modifies IPsec6 to fragment IPv6 packets that are
> locally generated as needed.
> 
> This version of the patch only fragments in tunnel mode, so that fragment
> headers will not be obscured by ESP in transport mode.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
