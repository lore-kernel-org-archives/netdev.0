From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Thu, 06 Nov 2014 22:13:13 -0500 (EST)
Message-ID: <20141106.221313.1375322315446025123.davem@davemloft.net>
References: <20141106082338.GA29800@gondor.apana.org.au>
	<20141106.122500.4643339498907490.davem@davemloft.net>
	<20141107015944.GB9101@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141107015944.GB9101@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 7 Nov 2014 09:59:44 +0800

> In that case it might be best to wait until those fixes hit net-next
> first before applying these patches as otherwise Stephen will get
> hit with some nasty merge conflicts.

I just merged net into net-next, so this barrier should no longer
be present.

Thanks.
