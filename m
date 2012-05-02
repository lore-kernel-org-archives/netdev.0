From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-05-01
Date: Wed, 02 May 2012 00:05:23 -0400 (EDT)
Message-ID: <20120502.000523.307160882398092059.davem@davemloft.net>
References: <20120501183157.GA2987@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120501183157.GA2987-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 1 May 2012 14:31:58 -0400

> Part of these are Bluetooth -- Gustavo says:
> 
> "A few more fixes to 3.4, there is three new device id supported, a missing
> break and a fix to retain key during the connection."
> 
> Along with those, we have some 802.11 fixes.  Felix gives us a fix
> for sending EAP frames for AP VLAN interfaces.  Franky gives us
> two brcmfmac fixes, one for missed event completions and another
> for an improperly initialized function pointer.  Grazvydas Ignotas
> gives us a couple of wl1251 fixes for some improperly freed memory.
> Jonathan Bither gives us an ath5k fix for an AHB resource leak.
> Seth Forshee gives us a b43 fix to avoid a crash when b43 fails to
> properly initialize.  Finally, Wey-yi gives us a fixup for a previously
> merged fix to use the correct firmware for certain iwlwifi devices.
> 
> The brcmfmac fixes are bigger than I would like to see.  But since
> they are isolated to that driver and fix real problems, I felt they
> were still acceptable.
> 
> Please let me know if there are problems!

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
