From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: add new device id's
Date: Mon, 02 Feb 2009 16:33:00 -0800 (PST)
Message-ID: <20090202.163300.56532261.davem@davemloft.net>
References: <49870A39.8000806@option.com>
	<20090202.140240.230022378.davem@davemloft.net>
	<4ADF55C1EB3643428CD4FAE5C129EF950258CD97@SRV-SATURNUS.OPTION.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ADF55C1EB3643428CD4FAE5C129EF950258CD97-XlSf7ELR9ZHcV2kYEOvnW/lB2ga7rPjFZkel5v8DVj8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Filip Aben" <F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Tue, 3 Feb 2009 01:26:14 +0100

> > -----Original Message-----
> > From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> > Sent: maandag 2 februari 2009 23:03
> > To: Filip Aben
> > Cc: gregkh-l3A5Bk7waGM@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: Re: [PATCH] hso: add new device id's
> > 
> > Why won't 0xaf0/0xd051 ever be used?
> > 
> > You should explain such things in your commit message,
> > that way I don't have to ask.
> 
> That ID was used in an internal engineering version of a device and 
> will never see commercial light.
> Even if this ID will be 'recycled' in the future, which is very
> unlikely, 
> I don't know what kind of device will be behind it. Therefore it's safer
> to remove it.

Great, please add that information to the commit message
and resend your patch.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
