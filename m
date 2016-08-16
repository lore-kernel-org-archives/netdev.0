From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC PATCH v5 3/3] net: phy: Add gmiitorgmii converter support
Date: Tue, 16 Aug 2016 06:30:00 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5E2756@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-4-git-send-email-appanad@xilinx.com>
 <20160815213059.GK24664@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Punnaiah Choudary Kalluri" <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160815213059.GK24664-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> 
> > Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> > ---
> > Thanks a lot Andrew for your inputs.
> > Changes for v5:
> > --> Fixed return values in the probe as suggested by punnaiah.
> > --> Added a mask for the converter speed as suggested by punnaiah.
> > +/* Xilinx GMII2RGMII Converter driver
> > + *
> > + * Copyright (C) 2016 Xilinx, Inc.
> > + *
> > + * Author: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> 
> Not cool
> 
> https://github.com/lunn/linux/commit/03d375489ceb56e171056f44d0fe9c34ca
> 5a098e
> 
> Notice the
> 
> Not-Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> 
> and the Copyright i added?
> 
> In various emails i gave you the basic idea how this should be done, a framework
> of code, and then took your code which did not even compile and made the core
> of it work. This is as much my code as your code, so i expect my Copyright to be
> kept on this code. And since this is my code, i need to give a Signed-off-by,
> which i was not yet ready to give since the code was not complete or working.
> 
> Please put both my Copyright back and Not-Signed-Off-by back and post the
> next version as RFC. Once i'm happy this code is O.K, i will give you a Signed-off-
> by.

Sorry I should have been included your copyright.

I missed it...
I didn't included your SOF because.
AFAIK without explicit permission of the other person we shouldn't include SOF.
That's why I didn't included your SOF and thanked for your efforts after SOF.
Sorry if my understanding is wrong.
 
There are few comments for this patch series and I fixed it and sent the v6 version.
 V6 version of patch series already got merged on the net-next.

Sent the patch by updating the driver with your copy right 
"net: phy: Update copyright info".

Sorry for the noise will fix these type of issues next time onwards...

Regards,
Kedar.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
