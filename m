From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Sat, 14 Jul 2007 20:41:16 -0700 (PDT)
Message-ID: <20070714.204116.23012949.davem@davemloft.net>
References: <20070712204137.GB14486@tuxdriver.com>
	<20070714.185935.18577806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070714.185935.18577806.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Sat, 14 Jul 2007 18:59:35 -0700 (PDT)

> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Thu, 12 Jul 2007 16:41:38 -0400
> 
> > This request is based off net-2.6, as it requires a patch that is in
> > net-2.6 but not yet in Linus' tree (b3d88ad49a0623d09efcf998beb26288c8029f75).
>  ...
> >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem
> 
> Pulled, thanks John!

A warning to look into:

net/mac80211/ieee80211.c: In function $,1rx(Bieee80211_register_hw$,1ry(B:
net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
