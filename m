From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/1] net/xfrm/xfrm_output.c: move EXPORT_SYMBOL
Date: Wed, 14 May 2014 13:45:38 +0200
Message-ID: <20140514114538.GA32371@secunet.com>
References: <20140512195434.ae5e323fe8394354b224a03e@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm <akpm@linux-foundation.org>, <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140512195434.ae5e323fe8394354b224a03e@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please Cc netdev@vger.kernel.org on all future networking patches.

On Mon, May 12, 2014 at 07:54:34PM +0200, Fabian Frederick wrote:
> Fix checkpatch warning:
> "WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable"
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied to ipsec-next, thanks!
