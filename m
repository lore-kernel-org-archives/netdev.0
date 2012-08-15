From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-08-15
Date: Wed, 15 Aug 2012 15:52:06 -0700 (PDT)
Message-ID: <20120815.155206.172710419448408328.davem@davemloft.net>
References: <20120815185409.GA2137@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120815185409.GA2137-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 15 Aug 2012 14:54:10 -0400

> This is a batch of updates intended for 3.7.  The ath9k, mwifiex,
> and b43 drivers get the bulk of the commits this time, with a handful
> of other driver bits thrown-in.  It is mostly just minor fixes and
> cleanups, etc.
> 
> Also included is a Bluetooth pull, with a lot of refactoring.
> Gustavo says:
> 
> 	"These are the changes I queued for 3.7. There are a many
> 	small fixes/improvements by Andre Guedes. A l2cap channel
> 	refcounting refactor by Jaganath. Bluetooth sockets now
> 	appears in /proc/net, by Masatake Yamato and Sachin Kamat
> 	changes ours drivers to use devm_kzalloc()."
> 
> Please let me know if there are problems!

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
