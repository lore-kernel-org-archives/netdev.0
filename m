From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sat, 15 Sep 2007 11:25:49 -0700 (PDT)
Message-ID: <20070915.112549.79067357.davem@davemloft.net>
References: <20070915132220.GE6060@tuxdriver.com>
	<20070915170018.GC18930@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070915170018.GC18930-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Sat, 15 Sep 2007 13:00:18 -0400

> Come to think of it, this driver will depend on some of the mac80211
> patches Dave M. has queued for net-2.6.24.  Perhaps it would be better
> if Dave were to merge it with his tree?
> 
> Jeff, if you have no objection then please sign-off/ack/whatever so
> davem can see it.  Dave, in that case please pull this to net-2.6.24.

There are a lot of things to sort out :-)

What I'm going to try and accomplish right now is:

1) Rebase my tree, I just finished that.
2) Integrate linville's upstream-davem stuff into net-2.6.24
3) Integrate Jeff's upstream branch into net-2.6.24
4) Integrate linville's adm8211 driver into net-2.6.24

We'll see how well that goes.
