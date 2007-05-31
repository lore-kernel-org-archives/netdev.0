From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/4] mac80211 fixes for 2.6.22
Date: Thu, 31 May 2007 01:25:08 -0700 (PDT)
Message-ID: <20070531.012508.18299215.davem@davemloft.net>
References: <20070530182538.GB3610@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070530182538.GB3610-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 30 May 2007 14:25:38 -0400

> Some bug fixes that should be applied to 2.6.22:
> 
>       mac80211: fail back to use associate from reassociate
>       mac80211: fix memory leak when defrag fragments
>       mac80211: always set carrier status on open
>       mac80211: avoid null ptr deref in ieee80211_ibss_add_sta
> 
> These are also available in the wireless-2.6 git tree:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git mac80211
> 
> Please apply at your earliest convenience!

Looks good, pulled, thanks a lot John.
