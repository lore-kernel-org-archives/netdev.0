From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-11-28
Date: Tue, 29 Nov 2011 09:22:52 +0100
Message-ID: <1322554972.4110.0.camel@jlt3.sipsolutions.net>
References: <20111128200221.GD2681@tuxdriver.com>
	 (sfid-20111128_211553_792888_D5B25BB4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111128200221.GD2681-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> (sfid-20111128_211553_792888_D5B25BB4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-28 at 15:02 -0500, John W. Linville wrote:

> Johannes Berg (12):

>       mac80211: use skb list for fragments
>       mac80211: move fragment flag adjustment
>       mac80211: make TX LED handling independent of fragmentation
>       mac80211: transmit fragment list to drivers

Since you included these patches, can you please pick up "mac80211: fix
TX warning" relatively quickly? It fixes a harmless but possibly
recurring WARN_ON in this code.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
