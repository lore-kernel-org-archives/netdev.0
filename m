From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Mon, 29 Mar 2010 14:18:26 -0700
Message-ID: <1269897506.9242.10.camel@Linuxdev3>
References: <1269791821.11714.202.camel@localhost.localdomain>
	 <4BAFAA2C.8060604@earthlink.net>
	 <1269894593.11714.215.camel@localhost.localdomain>
	 <20100329.134144.57458224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org" <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org" <sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org>,
	"dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100329.134144.57458224.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-03-29 at 13:41 -0700, David Miller wrote:
> From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Date: Mon, 29 Mar 2010 13:29:53 -0700
> 
> > because they are not NIC cards. They just use Ethernet emulation. And
> > they also require a management interface to setup APN and activate them
> > first.
> > 
> > It is important that we tell userspace about the type of a network
> > interface. We do the same for WiMAX and WiFi btw.
> 
> I completely agree with Marcel on this, please fix the device
> type.
> 
Thank you all for reviewing the sierra_net driver and for your comments.
We fixed the device type, re-tested and re-submitted the driver patch.
Regards,
Elina


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
