From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 12 Nov 2013 09:15:49 -0800
Message-ID: <20131112171549.GB4925@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73F1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73F1-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 08, 2013 at 11:07:41AM -0000, David Laight wrote:
> > While this change improves things a lot (it runs for 20 minutes rather than
> > a few seconds), there is still something else wrong.
> 
> Almost certainly caused by an unrelated local change.

Ok, good, I was concerned there was another issue we were missing.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
