From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2011-06-17
Date: Fri, 17 Jun 2011 15:01:35 -0400 (EDT)
Message-ID: <20110617.150135.1664074829629603538.davem@davemloft.net>
References: <20110617173613.GC6820@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110617173613.GC6820-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 17 Jun 2011 13:36:14 -0400

> Here is a batch of fixes intended for 3.0.  Included are a regression
> for mwl8k which caused CCMP encryption to fail on that device, and an
> mwifiex fix for a null pointer dereference.  Also included is a batch
> of Bluetooth fixes from Gustavo, including a regression fix for BT 1.1
> devices, a fix for shutdown of SCO devices, a fix for an information
> leak, and a silly error-checking fix that I thought was worth including
> to prevent misinterpreting bad data as device command options.
> 
> Please let me know if there are problems!

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
