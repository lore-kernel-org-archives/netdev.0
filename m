From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-08-19
Date: Thu, 19 Aug 2010 16:59:51 -0700 (PDT)
Message-ID: <20100819.165951.200388018.davem@davemloft.net>
References: <20100819174638.GC2672@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100819174638.GC2672-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 19 Aug 2010 13:46:38 -0400

> This collection of fixes intended for 2.6.36 includes a few that look
> bigger than they really are.  The one from Joe Perches corrects a number
> of inadvertant upper->lower case conversion from an earlier patch
> already in 2.6.36.  The ones from Wey-Yi Guy change a timer value in a
> number of device-dependent data structures in order to avoid excessive
> firmware resets for those devices.
> 
> In addition to those, the one from Johannes Berg gives iwl3945 its own
> filter flag function since sharing the iwlagn version has created
> regressions for iwl3945.  The one from me corrects a DMA API misuse in
> ipw2100 that results in warning backtraces.
> 
> Please let me know if there are problems!

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
