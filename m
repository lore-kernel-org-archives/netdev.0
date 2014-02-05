From: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Subject: Re: [RFT 1/2] xhci 1.0: Limit arbitrarily-aligned scatter gather.
Date: Wed, 5 Feb 2014 23:40:14 +0100
Message-ID: <20140205224015.19363.qmail@stuge.se>
References: <cover.1391544195.git.sarah.a.sharp@linux.intel.com> <baa32650c285a89671030370f638e2203171b3a0.1391544195.git.sarah.a.sharp@linux.intel.com> <063D6719AE5E284EB5DD2968C1650D6D0F6B8C70@AcuExch.aculab.com> <20140205210847.GD12087@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?utf-8?B?QmrDuHJu?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140205210847.GD12087@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sarah,

Sarah Sharp wrote:
> I'm simply trying to see how much of a priority it is to fix this.
> I really want to re-architect the code and do this right, and it
> will take some time.

Awesome! I think wanting to do it right is very close to
desire for perfection, or at the very least correctness. :)

I do appreciate having to prioritize.


//Peter
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
