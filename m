From: Alex Deucher <alexdeucher@gmail.com>
Subject: Re: Marvell 88W8310 and 88E8050 PCI Express support
Date: Thu, 24 Feb 2005 18:08:50 -0500
Message-ID: <a728f9f905022415084f82f769@mail.gmail.com>
References: <a728f9f905022413465b96acd4@mail.gmail.com>
	 <20050224143509.4fe2a6a8@dxpl.pdx.osdl.net>
Reply-To: Alex Deucher <alexdeucher@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050224143509.4fe2a6a8@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Feb 2005 14:35:09 -0800, Stephen Hemminger
<shemminger@osdl.org> wrote:
> On Thu, 24 Feb 2005 16:46:34 -0500
> Alex Deucher <alexdeucher@gmail.com> wrote:
> 
> > I've noticed most of the new AMD64 chipsets now include integrated
> > marvell GigE and wifi chips onboard.  I haven't been able to find much
> > on the status of linux support for these chips.  Apparently the PCIE
> > GigE chip only works with sk98lin
> 
> You need to use the version from SysKonnect.  If you look at the source
> for that, you will see why I started on the skge driver.
> 
> 
> > http://www.ussg.iu.edu/hypermail/linux/kernel/0502.1/0010.html
> > Does anyone know if support for the chip is being added to skge?
> 
> As soon as I get the hardware (on order), or a donation of a new system.
> Then I will report the interface from sk98lin.
> 
> > The
> > 88W8310 doesn't seem to be supported at all, at least not that I can
> > see.  Does anyone know the status of the 88W8310?  Are there any
> > experimental drivers?  Is Marvell friendly to opensource?  Are the
> > databooks available?
> 
> If you find databook for Yukon 2 chipset let me know.  I found the original
> Yukon and Genesis manuals, but nothing newer.
> 

Thanks for the info.  If I get a board with a yukon 2, I'd be happy to
help.  I don't suppose you know anything about the wifi chip
(88W8310)?  Jeff?

Thanks,

Alex
