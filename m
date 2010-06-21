From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] lasi82596: fix netdev_mc_count conversion
Date: Mon, 21 Jun 2010 17:33:09 -0400
Message-ID: <20100621213309.GB20317@bombadil.infradead.org>
References: <20100619223524.GA6018@p100.box> <20100619224139.GA6158@p100.box> <20100621.135050.48492866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: deller@gmx.de, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, linux-parisc@vger.kernel.org,
	kyle@mcmartin.ca, jpirko@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100621.135050.48492866.davem@davemloft.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 21, 2010 at 01:50:50PM -0700, David Miller wrote:
> From: Helge Deller <deller@gmx.de>
> Date: Sun, 20 Jun 2010 00:41:39 +0200
> 
> > Fix commit 4cd24eaf0 (net: use netdev_mc_count and netdev_mc_empty when
> > appropriate)
> > 
> > Signed-off-by: Helge Deller <deller@gmx.de>
> 
> Applied, please CC: netdev@vger.kernel.org when posting networking
> patches in the future, thanks.
> 

Thanks for catching this, Dave.

--Kyle
