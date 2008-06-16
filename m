From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/12]: Proper compat WEXT support.
Date: Mon, 16 Jun 2008 02:21:04 -0700 (PDT)
Message-ID: <20080616.022104.217167562.davem@davemloft.net>
References: <20080604184955.B033.40F06B3A@sm.sony.co.jp>
	<20080612.225332.193703791.davem@davemloft.net>
	<20080616174509.B048.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080616174509.B048.40F06B3A-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Date: Mon, 16 Jun 2008 18:15:12 +0900

> With this new patch #12, it worked OK for me.   I tested on my PS3 with:
> 
>   - wireless_tools version 28 and 29.  Both 64 and 32-bit compiled
>     iwlist and iwconfig
>   - wpa_supplicant 0.6.x, 64 and 32-bit compiled
>   - gelic and zd1211 driver
>   
> 
> checkpatch.pl complained some error/warnings on the patches #7, #9 and
> #12.  It seemed that most of them were inherited from the original code,
> some seemed like newly created ones, like 80-characters over warnings in
> net/mac80211/mlme.c.  We might want to fix them?
> 
> Anyway the code works fine.  Again, thank you!

Thank you very much for testing.

I will respin my tree and look into the checkpatch warnings
so that I may make a final submission to John Linville.

Arigato gozaimasu!!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
