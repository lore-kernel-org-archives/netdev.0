From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning in Linus' tree
Date: Tue, 25 May 2010 18:54:14 -0700 (PDT)
Message-ID: <20100525.185414.226791146.davem@davemloft.net>
References: <20100526114306.5fa6fa0e.sfr@canb.auug.org.au>
	<20100526015110.GA21587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100526015110.GA21587@gondor.apana.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 26 May 2010 11:51:10 +1000

> cls_cgroup: Initialise classid when module is absent
> 
> When the cls_cgroup module is not loaded, task_cls_classid will
> return an uninitialised classid instead of zero.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
