From: Bernd Schubert <Bernd.Schubert@tc.pci.uni-heidelberg.de>
Subject: Re: network speed extremly slowed down
Date: Mon, 14 Mar 2005 22:16:30 +0100
Message-ID: <20050314211630.GA20122@fubini.pci.uni-heidelberg.de>
References: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de> <20050314115757.789a82d4@dxpl.pdx.osdl.net> <20050314121509.70dcd129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050314121509.70dcd129.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2005 at 12:15:09PM -0800, David S. Miller wrote:
> On Mon, 14 Mar 2005 11:57:57 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Are there any errors reported? Cpu time sees high perhaps the console log
> > is filling with messages or something.
> 
> Or he has CONFIG_DEBUG_SLAB enabled in his kernel config.
> So many people do this unknowingly.
> 

No, no unusual error reports, but full debugging is enabled, so also
CONFIG_DEBUG_SLAB.
Recompiling now with only CONFIG_MAGIC_SYSRQ support.

Thanks,
	Bernd 
