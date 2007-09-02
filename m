From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: Oops in 2.6.23-rc5
Date: Sun, 2 Sep 2007 14:12:22 +0200 (CEST)
Message-ID: <alpine.DEB.0.999.0709021407240.7103@sheep.housecafe.de>
References: <E1IRgwF-0004G0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966126AbXIBMMx@vger.kernel.org>
In-Reply-To: <E1IRgwF-0004G0-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007, Herbert Xu wrote:
> You want this patch (by davem).

I applied the patch and the box is up for 1hr now. Since I was able to 
reproduce the oops pretty reliable with this bittorrent thingy, I 
did the same a few times now, but the box did NOT crash :)

> Unfortunately people are travelling so I'm not sure when it'll
> get picked up by Linus.

I've seen this patch only in:
http://article.gmane.org/gmane.linux.network/70781

And, for the archives, a simliar looking error report:
http://article.gmane.org/gmane.linux.network/70777

Thanks for the quick reply, Herbert!

Christian.
-- 
BOFH excuse #297:

Too many interrupts
