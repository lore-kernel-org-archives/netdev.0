From: "David S. Miller" <davem@davemloft.net>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 13:53:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915135308.78bf74f0.davem@davemloft.net>
References: <4148991B.9050200@pobox.com>
	<Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
	<1095275660.20569.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paul@clubi.ie, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1095275660.20569.0.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 20:14:22 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Mer, 2004-09-15 at 21:04, Paul Jakma wrote:
> > The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI 
> > card running Linux. Or is that what you were referring to with 
> > "<cards exist> but they are all fairly expensive."?
> 
> Last time I checked 2Ghz accelerators for intel and AMD were quite cheap
> and also had the advantage they ran user mode code when idle from
> network processing.

ROFL, and this is my position on this topic as well.

There are absolutely no justified economics in these
TOE engines.  By the time you deploy them, the cpus
and memory catch up and what's more those are general
purpose and not just for networking as David Stevens
and others have said.

TOE is just junk, and we'll reject any attempt to put
that garbage into the kernel.
