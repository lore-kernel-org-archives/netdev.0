From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Mon, 14 Jul 2008 20:45:32 -0700 (PDT)
Message-ID: <20080714.204532.116542087.davem@davemloft.net>
References: <20080714192302.GA2541@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080714192302.GA2541-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 14 Jul 2008 15:23:02 -0400

> Here is one last(?) round of miscellaneous patches I hope to get into
> 2.6.27.  There are mostly driver updates, including a sizable iwlwifi
> set of changes.
> 
> Please let me know if there are problems!

Pulled into net-next-2.6, thanks John.

If someone could fix the following wireless warnings I'd appreciate
it.

Thanks!

drivers/net/wireless/rt2x00/rt2x00mac.c: In function 'rt2x00mac_conf_tx':
drivers/net/wireless/rt2x00/rt2x00mac.c:557: warning: comparison is always true due to limited range of data type
drivers/net/wireless/b43/main.c: In function 'b43_qos_params_upload':
drivers/net/wireless/b43/main.c:3085: warning: comparison is always false due to limited range of data type
drivers/net/wireless/b43/main.c:3090: warning: comparison is always false due to limited range of data type
drivers/net/wireless/b43/main.c:3095: warning: comparison is always false due to limited range of data type
drivers/net/wireless/b43/main.c:3100: warning: comparison is always false due to limited range of data type
drivers/net/wireless/iwlwifi/iwl-led.c: In function 'iwl_get_blink_rate':
drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 6 has type 's64'
drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 7 has type 'u64'
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
