From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 11:15:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915111522.02153d0c.davem@davemloft.net>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	<414808F3.70104@draigBrady.com>
	<16712.14153.683690.710955@robur.slu.se>
	<41484AC2.8090408@draigBrady.com>
	<20040915181516.GB2678@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040915181516.GB2678@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 20:15:16 +0200
Harald Welte <laforge@netfilter.org> wrote:

> On Wed, Sep 15, 2004 at 02:59:30PM +0100, P@draigBrady.com wrote:
> > Interesting info thanks!
> > It would be very interesting to see the performance of PCI express
> > which should not have the bus arbitration issues.
> 
> Unfortunately there is no e1000 for PCI Express available yet... only
> Marvell-Yukon and syskonnect single-port boards so far :(

There are TG3 chips that support PCI-Express.  These are
the 5705/5750 variants.

I don't know if actual boards are being sold, or if these
are currently on-board only.
