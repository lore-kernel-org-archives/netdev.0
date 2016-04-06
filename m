From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg
Date: Wed,  6 Apr 2016 18:39:13 +0000 (UTC)
Message-ID: <20160406183913.BE8E8615EF@smtp.codeaurora.org>
References: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Use a more common logging style.
> 
> Miscellanea:
> 
> o Add specific logging macros for ALGORITHM and INTERFACE types
> o Output the messages at KERN_DEBUG
> o Coalesce formats
> o Align arguments
> o Whitespace style adjustments for only these changes
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks, applied to wireless-drivers-next.git. There were some conflicts but
3-way merge was able to fix them. Please double check still.

Applying: rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.h
Auto-merging drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
Auto-merging drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c

Kalle Valo
