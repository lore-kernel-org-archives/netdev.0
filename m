From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-05-05
Date: Tue, 05 May 2009 12:00:34 -0700 (PDT)
Message-ID: <20090505.120034.213663073.davem@davemloft.net>
References: <20090505181009.GA2788@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090505181009.GA2788-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 5 May 2009 14:10:09 -0400

> Yet another round of fixes intended for 2.6.30...
> 
> Included is the removal of another unnecessary EXPORT_SYMBOL that seems
> to be irritating some versions of GCC, the correction of a WARN_ON check
> that generates spurious log noise, a fix for a missing length value that
> leads to bad data being passed to userland, the correction of a WARN in
> iwl_set_tkip_dynamic_key_info, fixes for a couple of cfg80211 Oopsen, a
> one-line comment correction in cfg80211, and a couple of memory
> corruption fixes related to mac80211 rate control algorithms.  One of
> these last two looks a little big, but it is mostly moving a hunk of
> code around.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Pulled, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
