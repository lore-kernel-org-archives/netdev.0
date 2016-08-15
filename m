From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC PATCH v5 3/3] net: phy: Add gmiitorgmii converter support
Date: Mon, 15 Aug 2016 23:30:59 +0200
Message-ID: <20160815213059.GK24664@lunn.ch>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-4-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1470735283-23611-4-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
> Thanks a lot Andrew for your inputs.
> Changes for v5:
> --> Fixed return values in the probe as suggested by punnaiah.
> --> Added a mask for the converter speed as suggested by punnaiah.
> +/* Xilinx GMII2RGMII Converter driver
> + *
> + * Copyright (C) 2016 Xilinx, Inc.
> + *
> + * Author: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>

Not cool

https://github.com/lunn/linux/commit/03d375489ceb56e171056f44d0fe9c34ca5a098e

Notice the

Not-Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

and the Copyright i added?

In various emails i gave you the basic idea how this should be done, a
framework of code, and then took your code which did not even compile
and made the core of it work. This is as much my code as your code, so
i expect my Copyright to be kept on this code. And since this is my
code, i need to give a Signed-off-by, which i was not yet ready to
give since the code was not complete or working.

Please put both my Copyright back and Not-Signed-Off-by back and post
the next version as RFC. Once i'm happy this code is O.K, i will give
you a Signed-off-by.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
