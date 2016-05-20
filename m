From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for
	T4240-R1.0-R2.0
Date: Fri, 20 May 2016 06:05:45 +0000
Message-ID: <HE1PR04MB08891B37898C97E1800D701EF84B0@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<4448030.Zs8fVnr3nm@wuerfel>
	<HE1PR04MB0889B52134A43C0E7A452B7BF87C0@HE1PR04MB0889.eurprd04.prod.outlook.com>
	<5159406.HOFrj7pRfW@wuerfel> <1462937186.16584.77.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Bhupesh
	Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Rob
	Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, Q
To: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1462937186.16584.77.camel-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

Any comments? 
Please reply when you see the email since we want this eSDHC issue to be fixed soon.

All the patches are Freescale-specific and is to fix the eSDHC driver.
Could we let them merged first if you were talking about a new way of abstracting getting SoC version.


Thanks :)


Best regards,
Yangbo Lu

> -----Original Message-----
> From: Scott Wood [mailto:oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org]
> Sent: Wednesday, May 11, 2016 11:26 AM
> To: Arnd Bergmann; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Cc: Yangbo Lu; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; Mark Rutland;
> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Russell King; Bhupesh
> Sharma; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Joerg Roedel; Kumar Gala; linux-
> mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Yang-Leo Li;
> iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; Rob Herring; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> Claudiu Manoil; Santosh Shilimkar; Xiaobo Xie; linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> Qiang Zhao
> Subject: Re: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for T4240-
> R1.0-R2.0
> 
> On Thu, 2016-05-05 at 13:10 +0200, Arnd Bergmann wrote:
> > On Thursday 05 May 2016 09:41:32 Yangbo Lu wrote:
> > > > -----Original Message-----
> > > > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > > > Sent: Thursday, May 05, 2016 4:32 PM
> > > > To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> > > > Cc: Yangbo Lu; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > > > devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org;
> > > > linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > > > linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org foundation.org;
> > > > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mark Rutland; ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org;
> > > > Russell King; Bhupesh Sharma; Joerg Roedel; Santosh Shilimkar;
> > > > Yang-Leo Li; Scott Wood; Rob Herring; Claudiu Manoil; Kumar Gala;
> > > > Xiaobo Xie; Qiang Zhao
> > > > Subject: Re: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for
> > > > T4240-
> > > > R1.0-R2.0
> > > >
> > > > On Thursday 05 May 2016 11:12:30 Yangbo Lu wrote:
> > > > > IIRC, it is the same IP block as i.MX and Arnd's point is this
> > > > > won't even compile on !PPC. It is things like this that prevent
> > > > > sharing the driver.
> > >
> > > The whole point of using the MMIO SVR instead of the PPC SPR is so
> > > that it will work on ARM...  The guts driver should build on any
> > > platform as long as OF is enabled, and if it doesn't find a node to
> > > bind to it will return 0 for SVR, and the eSDHC driver will continue
> > > (after printing an error that should be removed) without the ability
> > > to test for errata based on SVR.
> >
> > It feels like a bad design to have to come up with a different method
> > for each SoC type here when they all do the same thing and want to
> > identify some variant of the chip to do device specific quirks.
> >
> > As far as I'm concerned, every driver in drivers/soc that needs to
> > export a symbol to be used by a device driver is an indication that we
> > don't have the right set of abstractions yet. There are cases that are
> > not worth abstracting because the functionality is rather obscure and
> > only a couple of drivers for one particular chip ever need it.
> >
> > Finding out the version of the SoC does not look like this case.
> 
> I'm open to new ways of abstracting this, but can that please be
> discussed after these patches are merged?  This patchset is fixing a
> problem, the existing abstraction is unappealing and not widely adopted,
> a new abstraction is not ready, and we're only touching code for our
> hardware.
> 
> Oh, and the existing abstraction isn't even "existing".  I don't see any
> examples where soc_device is being used like this -- or even any way for
> a driver (the one consuming the information, not the soc "driver") to get
> a reference to the soc_device that's been registered short of searching
> for the device object by name -- and you're asking for new functionality
> in drivers/base/soc.c.
> 
> > > > I think the first four patches take care of building for ARM, but
> > > > the problem remains if you want to enable COMPILE_TEST as we need
> > > > for certain automated checking.
> > >
> > > What specific problem is there with COMPILE_TEST?
> >
> > COMPILE_TEST is solvable here and the way it is implemented in this
> > case (selecting FSL_GUTS from the driver) indeed looks like it works
> > correctly, but it's still awkward that this means building the SoC
> > specific ID stuff into the vmlinux binary for any driver that uses
> > something like that for a particular SoC.
> 
> Please keep in mind that this is a Freescale-specific driver... it's not
> as if we're attaching this dependency to common SDHCI code.
> 
> >
> > > > > Dealing with Si revs is a common problem. We should have a
> > > > > common solution. There is soc_device for this purpose.
> > > >
> > > > Exactly. The last time this came up, I think we agreed to
> > > > implement a helper using glob_match() on the soc_device strings.
> > > > Unfortunately this hasn't happened then, but I'd still prefer that
> > > > over yet another vendor-specific way of dealing with the generic
> issue.
> > >
> > > soc_device would require encoding the SVR as a string and then
> > > decoding the string, which is more complicated and error prone than
> > > having platform-specific code test a platform-specific number.
> >
> > You already need to encode it as a string to register the soc_device,
> 
> No we don't, because we don't already register a soc_device on arm64 or
> ppc (and it looks like whatever does get registered on at least some
> relevant
> arm32 chips is not particularly useful).
> 
> > and the driver just needs to pass a glob string, so the only part that
> > is missing is the generic function that takes the string from the
> > driver and passes that to glob_match for the soc_device.
> 
> "just"
> 
> And what would the glob look like?
> 
> I'd rather not write kernel code as if it were a shell/Perl script.
> 
> > > And when would it get registered on arm64, which doesn't have
> > > platform code?
> >
> > Whenever the soc driver is loaded, as is the case now. The match
> > function can return -EPROBE_DEFER if no SoC device is registered yet.
> 
> That's too late for some places where we need access to SVR, e.g. clock
> drivers (which use CLK_OF_DECLARE and are initialized very early, not as
> part of the driver model and thus can't defer).  Currently we have an
> #ifdef CONFIG_PPC for this in drivers/clk/clk-qoriq.c... Maybe we should
> have done that here as well, and saved some grief. :-)  At least until an
> erratum pops up on an ARM-based chip.
> 
> And what happens if we're running on arm32, and thus the arch code
> already registered an soc_device with a different (and less useful)
> encoding?
> 
> -Scott
