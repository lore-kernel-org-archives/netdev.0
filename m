From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 0/6] netdev: Octeon MGMT new driver + octeon_ethernet
	updates.
Date: Wed, 14 Oct 2009 11:04:29 +0200
Message-ID: <20091014090429.GB17300@linux-mips.org>
References: <4ACD1F4E.8090603@caviumnetworks.com> <20091014.010913.21176323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ddaney@caviumnetworks.com, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20091014.010913.21176323.davem@davemloft.net>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2009 at 01:09:13AM -0700, David Miller wrote:

> > The main thrust of this patch set is to add a driver for the Cavium
> > Networks Octeon processor's MII (Management port) Ethernet devices.
> > Since it shares an mdio bus with the existing octeon-ethernet driver,
> > there is also some rearrangement of that code.
> 
> Ralf how do you want to handle this patch set?
> 
> Since it's mostly MIPS infrastructure bits, please just add my:
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 
> to the commit that adds the actual driver under drivers/net/
> and you can merge all of it via your tree.

Okay, will merge.  Thanks!

  Ralf
