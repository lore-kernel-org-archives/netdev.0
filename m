From: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Mon, 10 Feb 2014 09:52:36 -0600
Message-ID: <1392047556.17499.0.camel@linux-builds1>
References: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
	 <20140209.180642.1194468196963903290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140209.180642.1194468196963903290.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-02-09 at 18:06 -0800, David Miller wrote:
> From: <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 6 Feb 2014 17:19:54 -0600
> 
> > +MODULE_ALIAS("platform:socfpga-dwmac");
> > +MODULE_AUTHOR("Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>");
> > +MODULE_LICENSE("GPL v2");
> > +MODULE_DESCRIPTION("Altera SOCFPGA DWMAC Glue Layer");
> > +
> 
> Do not add stray empty lines at the end of files.  Your second patch
> has this problem is a few places too.
> 

Will fix in v3.

Thanks,
Dinh


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
