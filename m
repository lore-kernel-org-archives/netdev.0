From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v8, 1/7] Documentation: DT: update Freescale DCFG compatible
Date: Tue, 26 Apr 2016 02:43:10 +0000
Message-ID: <HE1PR04MB0889A68C6D275D3102382D8BF8630@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1461306464-19521-1-git-send-email-yangbo.lu@nxp.com>
	<1461306464-19521-2-git-send-email-yangbo.lu@nxp.com>
	<20160422131151.GJ10606@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Zhao Qiang <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Russell
	King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>, Scott Wood <scott.wood-3arQi8VN3Tc@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEmw@public.gmane.org
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160422131151.GJ10606@leverpostej>
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

Hi Mark,


> -----Original Message-----
> From: Mark Rutland [mailto:mark.rutland-5wv7dgnIgG8@public.gmane.org]
> Sent: Friday, April 22, 2016 9:12 PM
> To: Yangbo Lu
> Cc: linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org;
> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Scott Wood; Rob Herring;
> Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil; Bhupesh
> Sharma; Zhao Qiang; Kumar Gala; Santosh Shilimkar; Yang-Leo Li; Xiaobo
> Xie
> Subject: Re: [v8, 1/7] Documentation: DT: update Freescale DCFG
> compatible
> 
> On Fri, Apr 22, 2016 at 02:27:38PM +0800, Yangbo Lu wrote:
> > Update Freescale DCFG compatible with 'fsl,<chip>-dcfg' instead of
> > 'fsl,ls1021a-dcfg' to include more chips.
> >
> > Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
> > ---
> > Changes for v8:
> > 	- Added this patch
> > ---
> >  Documentation/devicetree/bindings/arm/fsl.txt | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/Documentation/devicetree/bindings/arm/fsl.txt
> > b/Documentation/devicetree/bindings/arm/fsl.txt
> > index 752a685..1d5f512 100644
> > --- a/Documentation/devicetree/bindings/arm/fsl.txt
> > +++ b/Documentation/devicetree/bindings/arm/fsl.txt
> > @@ -119,7 +119,7 @@ Freescale DCFG
> >  configuration and status for the device. Such as setting the
> > secondary  core start address and release the secondary core from
> holdoff and startup.
> >    Required properties:
> > -  - compatible: should be "fsl,ls1021a-dcfg"
> > +  - compatible: should be "fsl,<chip>-dcfg"
> 
> Please list specific values expected for <chip>, while jusy saying <chip>
> may be more generic, it makes it practically impossible to search for the
> correct binding given a compatible string, and it's vague as to exaclty
> what <chip> should be.

[Lu Yangbo-B47093] Thanks for your comment. I will list the possible chips.

> 
> Thanks,
> Mark.
> 
> 
> 
> >    - reg : should contain base address and length of DCFG
> > memory-mapped registers
> >
> >  Example:
> > --
> > 2.1.0.27.g96db324
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe devicetree"
> > in the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo
> > info at  http://vger.kernel.org/majordomo-info.html
> >
