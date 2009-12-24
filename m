From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-12-24
Date: Thu, 24 Dec 2009 13:53:14 -0800 (PST)
Message-ID: <20091224.135314.193725771.davem@davemloft.net>
References: <20091224204722.GA678@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091224204722.GA678-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 24 Dec 2009 15:47:22 -0500

> Dave,
> 
> Here is the usual first batch of pent-up wireless patches after the
> merge window.  It is the usual collection of various driver updates
> along with a dozen or so mac80211/infrastructure changes.  There is
> still more, but lots/most of what remains is dependent not only on this
> batch but also on the fixes that only recently made it into net-next-2.6
> (and which are not yet in wireless-next-2.6).  So, something to look
> forward to... :-)
> 
> Please let me know if there are problems!

Let me know when it builds :-)

awk: /home/davem/src/GIT/net-next-2.6/net/wireless/genregdb.awk: line 29: regular expression compile failed (missing operand)
* Ignore *
awk: /home/davem/src/GIT/net-next-2.6/net/wireless/genregdb.awk: line 33: regular expression compile failed (missing operand)
* Ignore *
make[2]: *** [net/wireless/regdb.c] Error 2
make[2]: *** Waiting for unfinished jobs....
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
