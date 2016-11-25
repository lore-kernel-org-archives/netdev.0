From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 15:22:42 +0100
Message-ID: <20161125142242.GA22642@kroah.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
 <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <4e370db9-f6b2-edd4-537b-d5a45b2ddea1@pobox.com>
 <630308a2-1933-11a8-9b95-116e3f5a9d61@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <630308a2-1933-11a8-9b95-116e3f5a9d61-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 07:41:42AM -0500, Mark Lord wrote:
> On 16-11-25 07:34 AM, Mark Lord wrote:
> > On 16-11-25 04:53 AM, Greg KH wrote:
> >> Note, there are "cheap" USB monitors that can be quite handy and that work on Linux:
> >> 	http://www.totalphase.com/products/beagle-usb12/
> > 
> > USD$455/each in quantity, vs. USD$8 for the USB ethernet dongle.
> 
> Oh, wrong model.  That one doesn't do USB2.
> The USB2 version is a mere USD$1300 in quantity.
> 
> Seems like rather a lot of money just to report a bug in a USB driver.
> Perhaps the Linux Foundation might purchase one and loan it for this task?

You already have access to a USB analyzer you said, why would I try to
buy one and ship it around the world instead?  Makes no sense...

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
