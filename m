From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 29 Feb 2012 03:21:42 +0000
Message-ID: <1330485702.2512.22.camel@bwh-desktop>
References: <20120227121125.007c32f9aa7be2470d9e3356@canb.auug.org.au>
	 <20120226.230523.1906949835561978402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <sfr@canb.auug.org.au>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120226.230523.1906949835561978402.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-02-26 at 23:05 -0500, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 27 Feb 2012 12:11:25 +1100
> 
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/ethernet/sfc/rx.c between commit ff3bc1e75275 ("sfc: Fix
> > assignment of ip_summed for pre-allocated skbs") from Linus' tree and
> > commit db3395697cad ("sfc: Replace efx_rx_buffer::is_page and other
> > booleans with a flags field") from the net-next tree.
> > 
> > Just context changes.  I fixed it up (see below) and can carry the fix as
> > necessary.
> 
> I just merged net into net-next and resolved this conflict.

Thank you both.  I should have flagged this when sending the change for
the net tree.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
