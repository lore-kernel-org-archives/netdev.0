From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/3] net: Kill skb_copy_datagram_const_iovec
Date: Tue, 4 Nov 2014 11:38:18 +0800
Message-ID: <20141104033818.GA11149@gondor.apana.org.au>
References: <20141103002207.GA26588@gondor.apana.org.au>
 <20141103004503.GX7996@ZenIV.linux.org.uk>
 <20141103053751.GA27845@gondor.apana.org.au>
 <20141103.150553.633529234958324183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141103.150553.633529234958324183.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 03:05:53PM -0500, David Miller wrote:
>
> I'll see if I can make some progress converting the networking over
> to iov_iter.  It can't be that difficult... albeit perhaps a little
> time consuming.

OK great.  I'll try to convert tun/macvtap over to iov_iter.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
