From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 15:14:46 -0700 (PDT)
Message-ID: <20070919.151446.116351108.davem@davemloft.net>
References: <20070919181005.GB5483@tuxdriver.com>
	<46F19DD0.2050605@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46F19DD0.2050605-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date: Wed, 19 Sep 2007 23:08:16 +0100

> John, thanks a lot for your efforts, I hope you don't mind waiting one 
> extra release cycle for me to sort a few things out.

Having "a driver" is always better for users than having "no driver".
Please I ask you not to block this merge even if you think it is too
early.

Distribution vendors are going to merge this driver into their kernel
trees anyways.  And as Linus stated at the recent kernel summit, when
this happens and upstream doesn't merge the driver too, the process
has failed.

We have had huge issues with shit piling up in the wireless tree and
it has to stop sooner rather than later, and I'm going to make sure
it stops now.

So please don't feel compelled to fix "all the issues" before a merge.
Drivers will always have issues, and if we merge now you will get more
useful feedback, sooner, and users will have something to use rather
than no driver at all.

Thanks.
