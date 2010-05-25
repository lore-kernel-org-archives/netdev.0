From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Mon, 24 May 2010 23:56:04 -0700 (PDT)
Message-ID: <20100524.235604.35187142.davem@davemloft.net>
References: <20100525141046.975afe1f.sfr@canb.auug.org.au>
	<20100524.215851.207470612.davem@davemloft.net>
	<20100525051442.GA8480@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100525051442.GA8480@gondor.apana.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 25 May 2010 15:14:42 +1000

> On Mon, May 24, 2010 at 09:58:51PM -0700, David Miller wrote:
>> 
>> Herbert, can you take a look?
> 
> Sorry, I hadn't tested the built-in case.
> 
> cls_cgroup: Fix build error when built-in
> 
> There is a typo in cgroup_cls_state when cls_cgroup is built-in.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
