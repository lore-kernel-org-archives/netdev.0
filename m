From: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be
	misaligned
Date: Thu, 30 Jan 2014 17:35:08 +0100
Message-ID: <20140130163508.27016.qmail@stuge.se>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486@AcuExch.aculab.com> <20140130161721.25560.qmail@stuge.se> <063D6719AE5E284EB5DD2968C1650D6D0F6B553D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B553D-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> > Where's the 8k coming from?
> 
> My memory, I meant 16k :-(

No problem. But what about that alignment? It seems that userspace
needs to start caring about alignment with xhci, right?


//Peter
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
