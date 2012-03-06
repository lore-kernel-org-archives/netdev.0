From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 05 Mar 2012 21:17:23 -0500 (EST)
Message-ID: <20120305.211723.1982594845858465817.davem@davemloft.net>
References: <20120305131103.71d87f250accd238b7d7630e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, sbhatewara@vmware.com,
	eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120305131103.71d87f250accd238b7d7630e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 5 Mar 2012 13:11:03 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/vmxnet3/vmxnet3_drv.c between commit efead8710aad ("vmxnet3:
> Fix transport header size") from the net tree and commit 8bca5d1ebb8b
> ("vmxnet3: cleanup tso headers manipulation") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

I'm taking care of this right now, thanks Stephen.
