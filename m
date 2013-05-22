From: Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
Subject: Re: [PATCH] MIPS: OCTEON: Rename Kconfig
 CAVIUM_OCTEON_REFERENCE_BOARD to CAVIUM_OCTEON_SOC
Date: Wed, 22 May 2013 14:22:32 +0200
Message-ID: <20130522122232.GD10769@linux-mips.org>
References: <1369088378-13957-1-git-send-email-ddaney.cavm@gmail.com>
 <20130521220457.GF31836@blackmetal.musicnaut.iki.fi>
 <519BF01B.1010600@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-edac-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <519BF01B.1010600-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 03:07:23PM -0700, David Daney wrote:

> >>  config USB_OCTEON_OHCI
> >>  	bool "Octeon on-chip OHCI support"
> >>-	depends on CPU_CAVIUM_OCTEON
> >>+	depends on  CAVIUM_OCTEON_SOC
> >
> >Just a minor comment, here the extra whitespace after "depends on"
> >could be eliminated.
> >
> 
> Good point.  I will regenerate the patch to correct this.

I took care of that and queued the patch.

Thanks,

  Ralf
