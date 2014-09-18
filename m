From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] [trivial] wireless:rtlwifi: Fix typo in rtl wifi drivers
Date: Thu, 18 Sep 2014 00:45:27 -0500
Message-ID: <541A7177.3010100@lwfinger.net>
References: <1411010992-9999-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John W Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411010992-9999-1-git-send-email-standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/17/2014 10:29 PM, Masanari Iida wrote:
> This patch fix spelling typo "sleeped" in printk, found in
> multiple rtlwifi drivers.
>
> Signed-off-by: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/rtl8188ee/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8192ce/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8192de/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8723ae/phy.c | 2 +-
>   drivers/net/wireless/rtlwifi/rtl8723be/phy.c | 2 +-
>   7 files changed, 7 insertions(+), 7 deletions(-)

John,

Please do not apply this patch for two reasons. (1) It would interfere with the 
major changes that I will be sending in the next few days. (2) I have been 
favoring "sleeping" over "slept" as a substitute for "sleeped". If I change my 
mind, I will resubmit this patch with Masanari as the author.

Thanks,

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
