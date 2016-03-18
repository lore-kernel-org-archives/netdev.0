From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg
Date: Thu, 17 Mar 2016 20:37:38 -0700
Message-ID: <1458272258.9556.46.camel@perches.com>
References: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
	 <56EB6DD9.3000300@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56EB6DD9.3000300@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-17 at 21:54 -0500, Larry Finger wrote:
> On 03/17/2016 07:00 PM, Joe Perches wrote:
> > Use a more common logging style.

[ 300K+ quote without comment ]

> Joe,

Hi Larry.

> The patch looks good, but it has conflict in=A0
> drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c with=
 the patch=A0
> [PATCH 2/2] rtlwifi: btcoexist: Implement antenna selection that I su=
bmitted=A0
> yesterday.

No worries, it shouldn't be applied during the
merge window anyway.

The conflict is trivially resolved after the
merge window is over.

cheers, Joe
