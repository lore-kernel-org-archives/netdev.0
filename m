From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 22:21:09 -0800 (PST)
Message-ID: <20080130.222109.52073562.davem@davemloft.net>
References: <47A03D4D.5090301@fr.ibm.com>
	<20080130.054807.182676684.davem@davemloft.net>
	<47A16611.3000602@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47A16611.3000602-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Date: Thu, 31 Jan 2008 01:09:21 -0500

> David Miller wrote:
> > The latter.
> 
> So...  what to do about changes which are not bug fixes?  Such changes 
> should not go upstream immediately, because that's the standard rule for 
> merge windows.
> 
> And queueing them on our side just re-creates the same old situation we 
> just changed away from, after all.

I'm saying that everything should go to the net-2.6 tree right now.

When the merge window closes, net-2.6 will be for bug fixes only and
I'll hold off on creating net-2.6.26 for about a week so that people
concentrate on regression fixes.

Yes, things will pile up but I think it's appropriate to hold off on
merging features into the 2.6.26 queue for just one week.
