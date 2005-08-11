From: Matt Porter <mporter@kernel.crashing.org>
Subject: Re: [PATCH] emac: add support for platform-specific unsupported PHY features
Date: Thu, 11 Aug 2005 13:55:30 -0700
Message-ID: <20050811135530.G30033@cox.net>
References: <1123284725.27880.26.camel@rhino.az.mvista.com> <42FACE25.5080909@pobox.com> <1123792744.27734.30.camel@rhino.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wade Farnsworth <wfarnsworth@mvista.com>
Content-Disposition: inline
In-Reply-To: <1123792744.27734.30.camel@rhino.az.mvista.com>; from wfarnsworth@mvista.com on Thu, Aug 11, 2005 at 01:39:05PM -0700
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2005 at 01:39:05PM -0700, Wade Farnsworth wrote:
> On Wed, 2005-08-10 at 21:03, Jeff Garzik wrote:
> > Wade Farnsworth wrote:
> > > Hello,
> > > 
> > > This patch adds support to the ibm_emac driver for platform-specific
> > > unsupported PHY features.
> > > 
> > > The patch attempts to determine the highest speed and duplex when
> > > autonegotiation is unsupported.
> > > 
> > > -Wade Farnsworth
> > > 
> > > Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
> > 
> > Can you update this patch RE Eugene's comments?
> > 
> > 	Jeff
> > 
> 
> Sorry for the delay.  Here is the updated patch.

FWIW, akpm has the ppc32 relevant bits that go with this patch
pending now.

-Matt
