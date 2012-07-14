From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-07-12
Date: Fri, 13 Jul 2012 23:05:26 -0700 (PDT)
Message-ID: <20120713.230526.350857505278321316.davem@davemloft.net>
References: <20120712181539.GB25494@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120712181539.GB25494-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 12 Jul 2012 14:15:40 -0400

> Several drivers see updates: mwifiex, ath9k, iwlwifi, brcmsmac,
> wlcore/wl12xx/wl18xx, and a handful of others.  The bcma bus got a
> lot of attention from Hauke Mehrtens.  The cfg80211 component gets
> a flurry of patches for multi-channel support, and the mac80211
> component gets the first few VHT (11ac) and 60GHz (11ad) patches.
> This also includes the removal of the iwmc3200 drivers, since the
> hardware never became available to normal people.
> 
> Additionally, the NFC subsystem gets a series of updates.  According to
> Samuel, "Here are the interesting bits:
> 
> - A better error management for the HCI stack.
> - An LLCP "late" binding implementation for a better NFC SAP usage. SAPs are
>   now reserved only when there's a client for it.
> - Support for Sony RC-S360 (a.k.a. PaSoRi) pn533 based dongle. We can read and
>   write NFC tags and also establish a p2p link with this dongle now.
> - A few LLCP fixes."
> 
> Finally, this includes another pull of the fixes from the wireless
> tree in order to resolve some merge issues.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
