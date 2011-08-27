From: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 40372] New: Driver pegasus freeze networking
 very often so one must reboot to get it to work again
Date: Sat, 27 Aug 2011 14:05:52 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1108271356450.3459@fry.nucleusys.com>
References: <Pine.LNX.4.44L0.1108262113000.9188-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	csanyipal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1108262113000.9188-100000-pYrvlCTfrz9XsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Fri, 26 Aug 2011, Alan Stern wrote:

> On Fri, 26 Aug 2011, Andrew Morton wrote:
>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=40372
>>>
>>>            Summary: Driver pegasus freeze networking very often so one
>>>                     must reboot to get it to work again
>
>>> Hi,
>>>
>>> the driver pegasus freezes networking often so one must to reboot to get
>>> networking work again.
>>>
>>> At reboot the system hang.
>>>
>>> At this point one must press the Reset button of the PC Box because
>>> the system hangs forever. I can't see any messages on the console screen when I
>>> want to reboot at point when system freezes.
>
> How do you know the pegasus driver is responsible for this problem?
>
> Do any error messages show up if you want a few minutes before
> rebooting?  What does the dmesg log say?

The list of loaded modules is rather impressive.  Could you please reduce 
their number as much as possible and test again?

Without the kernel panic screen there's no easy way to determine what 
actually happened and which module caused the hang-up, so we'll need that 
as well.


 		Petko
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
