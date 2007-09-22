From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: ?^?H?G Re: ?^?H?G Re: [linux-usb-devel] Please pull
	'ssb-drivers' branch of wireless-2.6  -- aln.
Date: Sat, 22 Sep 2007 08:13:35 -0700
Message-ID: <20070922151335.GA5428@suse.de>
References: <OF2983FA30.A28D686E-ON4825735E.004F310B-4825735E.004F7C82@sdc.sercomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	linux-usb-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alninuo_Li-mw3RyXb2L4OHSoWHlOhhYg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OF2983FA30.A28D686E-ON4825735E.004F310B-4825735E.004F7C82-mw3RyXb2L4OHSoWHlOhhYg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 22, 2007 at 10:28:23PM +0800, Alninuo_Li-mw3RyXb2L4OHSoWHlOhhYg@public.gmane.org wrote:
> Hi Greg, 
>         It should be the right name now, apologize for the typo., anyway, 
> glad to get the response from u.
>         I think the usbserial crash, or the printk crash is a small bug, 
> likely interrupt handling, but since I have no much idea for the driver, 
> so I need some helpful advice to debug on, 
>         And also for now, we have no much time to move from 2.4 to 2.6, 
> since the time to market is no room for us, which means the full 
> integration for other feature points.

Again, no one supports 2.4 anymore, so you are on your own.  Remember,
the 2.4.20 kernel was released almost 5 _years_ ago.  There are numerous
security holes in that kernel, as well as bugs that have been fixed in
newer releases.  If you insist on using that release, you are on your
own.

good luck,

greg k-h
