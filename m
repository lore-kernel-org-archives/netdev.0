From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Network lockup under load
Date: Wed, 23 Nov 2005 07:40:08 +1100
Message-ID: <20051122204008.GA16049@gondor.apana.org.au>
References: <20051122164502.GA12498@tsunami.ccur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965173AbVKVUkU@vger.kernel.org>
To: Joe Korty <joe.korty@ccur.com>
Content-Disposition: inline
In-Reply-To: <20051122164502.GA12498@tsunami.ccur.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 04:45:02PM +0000, Joe Korty wrote:
> 
> To trigger the lockup, I do a 'scp -rp' of the kernel
> tree from a machine with a defective kernel to any other
> machine.  It triggers anywhere after the first file
> transfered, to perhaps 30 files transfered.

Please generate a stack backtrace of your processes using either
CTRL-SCROLLLOCK or SysRq.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
