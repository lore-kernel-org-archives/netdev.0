From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 15:32:56 -0700 (PDT)
Message-ID: <20070919.153256.10296833.davem@davemloft.net>
References: <46F19DD0.2050605@gentoo.org>
	<20070919.151446.116351108.davem@davemloft.net>
	<46F1A23D.8080606@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46F1A23D.8080606-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date: Wed, 19 Sep 2007 23:27:09 +0100

> zd1211rw-mac80211 does not currently add anything to the user experience 
> over the existing driver, other than automatic rate adaption which is 
> nice but hasn't proven itself to be of much importance given that the 
> existing driver has lots of happy users and has never done it.

Ok.

> Also, this merge has been proposed in a form other than what me and 
> Ulrich were envisioning (at least from earlier discussions). We want to 
> convert drivers/net/wireless/zd1211rw to mac80211 directly. This would 
> also avoid a rename and I think would save some hassle.
> 
> Sorry to be a pain, but I really would like some more time to catch up 
> and make some last changes. I haven't yet even looked at Johannes' 
> minimal filter flags implementation in the driver or Michael's fix.
> 
> Would you agree to let this wait until 2.6.25? You can hold me to that, 
> although Ulrich should also comment on if he thinks he'd be ready by then.

Fair enough, I'll remove the Z1211 driver during my next rebase.
