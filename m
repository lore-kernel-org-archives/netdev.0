From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-02
Date: Sun, 6 Jul 2008 10:07:42 +0300
Message-ID: <1ba2fa240807060007i572d054va60aa16b41cadce3@mail.gmail.com>
References: <20080630215651.GA666@tuxdriver.com>
	 <20080702193710.GA4682@tuxdriver.com>
	 <20080702202653.GA10719@tuxdriver.com>
	 <20080705.214752.85024966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080705.214752.85024966.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 6, 2008 at 7:47 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Wed, 2 Jul 2008 16:26:53 -0400
>
>> Here is another slew of updates for 2.6.27.  The bulk of this batch is
>> for iwlwifi, with some mac80211 and other bits thrown-in.
>>
>> Let me know if there are problems!
>
> Pulled and pushed back out to net-next-2.6, thanks.
>
> Here are some warnings I noticed during an allmodconfig build
> on sparc64, please fix:
>
> drivers/net/wireless/hostap/hostap_hw.c:3422: warning: 'prism2_suspend' defined but not used
> drivers/net/wireless/iwlwifi/iwl-rfkill.c:114: warning: label 'freed_rfkill' defined but not used

John what happened to to those patches?
http://marc.info/?l=linux-wireless&m=121489830307988&w=2
http://marc.info/?l=linux-wireless&m=121481826531792&w=2
Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
