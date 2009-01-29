From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-01-29
Date: Thu, 29 Jan 2009 15:30:04 -0800 (PST)
Message-ID: <20090129.153004.183284867.davem@davemloft.net>
References: <20090129212725.GB6085@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090129212725.GB6085-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 29 Jan 2009 16:27:25 -0500

> I present to you another round of patches intended for 2.6.29.  There is
> a MAINTAINERS patch that recognizes the reality that Michael Wu is no
> longer touching mac80211.  There is a power setting patch for rtl8187
> that corrects a functional regression, and a NULL pointer fix for
> iwlagn.  There are a couple of regulatory-related patches that are
> isolated and I think merit inclusion based on their nature.  Finally,
> there is an ath5k fix for an older problem that is more prevalent since
> the merge of "ath5k: ignore the return value of
> ath5k_hw_noise_floor_calibration" and which addresses kernel.org bugs
> 12068 and 12080.

Pulled, thanks a lot John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
