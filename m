From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 15 Jan 2015 01:06:38 -0500 (EST)
Message-ID: <20150115.010638.1588013062855266803.davem@davemloft.net>
References: <20150115134735.1e4612c6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, david.vrabel@citrix.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150115134735.1e4612c6@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 15 Jan 2015 13:47:35 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/xen-netfront.c between commit 900e183301b5 ("xen-netfront:
> use different locks for Rx and Tx stats") from the net tree and commit
> a55e8bb8fb89 ("xen-netfront: refactor making Tx requests") from the
> net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Thanks a lot Stephen, I just resolved this.
