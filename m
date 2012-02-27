From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Sun, 26 Feb 2012 23:05:23 -0500 (EST)
Message-ID: <20120226.230523.1906949835561978402.davem@davemloft.net>
References: <20120227121125.007c32f9aa7be2470d9e3356@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120227121125.007c32f9aa7be2470d9e3356@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 27 Feb 2012 12:11:25 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/sfc/rx.c between commit ff3bc1e75275 ("sfc: Fix
> assignment of ip_summed for pre-allocated skbs") from Linus' tree and
> commit db3395697cad ("sfc: Replace efx_rx_buffer::is_page and other
> booleans with a flags field") from the net-next tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

I just merged net into net-next and resolved this conflict.

Thanks!
