From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: network speed extremly slowed down
Date: Tue, 15 Mar 2005 12:34:31 +0100
Message-ID: <200503151234.33166.bernd.schubert@pci.uni-heidelberg.de>
References: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de> <20050314115757.789a82d4@dxpl.pdx.osdl.net> <20050314121509.70dcd129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050314121509.70dcd129.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 14 March 2005 21:15, David S. Miller wrote:
> On Mon, 14 Mar 2005 11:57:57 -0800
>
> Stephen Hemminger <shemminger@osdl.org> wrote:
> > Are there any errors reported? Cpu time sees high perhaps the console log
> > is filling with messages or something.
>
> Or he has CONFIG_DEBUG_SLAB enabled in his kernel config.
> So many people do this unknowingly.

Thanks a lot, disabling debugging support solved our network speed problems.

Thanks again,
 Bernd
