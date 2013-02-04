From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] pf_key/xfrm_algo: prepare pf_key and xfrm_algo for new
 algorithms without pfkey support
Date: Mon, 4 Feb 2013 09:09:14 +0100
Message-ID: <20130204080914.GC23291@secunet.com>
References: <20130131104038.6852.57446.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33493 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752701Ab3BDIJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 03:09:17 -0500
Content-Disposition: inline
In-Reply-To: <20130131104038.6852.57446.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2013 at 12:40:38PM +0200, Jussi Kivilinna wrote:
> Mark existing algorithms as pfkey supported and make pfkey only use algorithms
> that have pfkey_supported set.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied to ipsec-next.
Thanks a lot Jussi!
