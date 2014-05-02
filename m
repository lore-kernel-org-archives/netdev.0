From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/2] net/phy: micrel: Add DT configuration support
 and
Date: Fri, 02 May 2014 15:58:13 -0400 (EDT)
Message-ID: <20140502.155813.1370156727988237449.davem@davemloft.net>
References: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, xobs-nXMMniAx+RbQT0dZR+AlfA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hchaumette-HH5893ap9ioXz/+GnIZSFEEOCMrvLtNR@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1398764005-23855-1-git-send-email-hchaumette-HH5893ap9ioXz/+GnIZSFEEOCMrvLtNR@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hubert Chaumette <hchaumette-HH5893ap9ioXz/+GnIZSFEEOCMrvLtNR@public.gmane.org>
Date: Tue, 29 Apr 2014 11:33:23 +0200

>  - Adds DT configuration support for ksz9031
>  - Renames micrel-ksz9021.txt to micrel-ksz90x1.txt and adds ksz9031 binding
>    documentation
> 
> Changes since v2:
>  - Merged together ksz9031_load_{clk,data,ctrl}_skew_values()
>  - Added field length and number of fields prameter to account for registers
>   specificities
>  - Added binding documentation

These patches do not apply cleanly to net-next, please respin.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
