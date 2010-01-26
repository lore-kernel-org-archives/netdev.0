From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 04:16:10 -0800 (PST)
Message-ID: <20100126.041610.226004766.davem@davemloft.net>
References: <87k4v5nuej.fsf@purkki.valot.fi>
	<4B5ED254.7010104@trash.net>
	<877hr5nkx0.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kalle.valo-X3B1VOXEql0@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877hr5nkx0.fsf-ySPBbPOLdCfMApvqMRVM/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Date: Tue, 26 Jan 2010 13:51:55 +0200

> Let's take a bittorrent client as an example. The traffic it generates
> is not important and it doesn't matter if bittorrent packets have
> lower priority compared to other streams. What SO_PRIORITY value
> should all bittorrent clients to use to mark their packets as low
> priority (for example background class from IEEE 802.1d Annex G).

This is a local policy decision.

There is no universal way of doing any of this, really.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
