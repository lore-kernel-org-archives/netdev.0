From: Elias Oltmanns <eo-oA28OIkTjSVZXbeN9DUtxg@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Thu, 30 Oct 2008 00:40:09 +0100
Message-ID: <87iqrb2co6.fsf@denkblock.local>
References: <20081029231855.GD3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081029231855.GD3485-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> (John W. Linville's message
	of "Wed, 29 Oct 2008 19:18:55 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> wrote:
> Dave,
>
> Another quick round of fixes intended for 2.6.28...
>
> This includes fixes for bugs 11749 and 11845, fixes a reset-related
> regression in ath5k, fixes a Kconfig-related error for rt2x00, and
> fixes some sparse warnings and a possible buffer overrun in libertas.
> Also, it corrects a spelling error and marks Bob Copeland as an
> ath5k maintainer.
>
> Please let me know if there are problems!
>
> Thanks,
>
> John
>
> ---
>
> Individual patches are available here:
>
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/
>
> ---
>
> The following changes since commit 882716604ecf388b2ff09bc76eb2a752aa9cc76b:
[...]
> Elias Oltmanns (1):
>       ath5k: Fix reset sequence for AR5212 in general and RF5111 in particular

Pity, I just posted a *nicer* version of that patch for 2.6.28-rc2.
Well, it doesn't really matter all that much, I suppose.

Regards,

Elias
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
