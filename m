From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh: sh_eth: Add support ethtool
Date: Tue, 22 Feb 2011 10:10:37 -0800 (PST)
Message-ID: <20110222.101037.112590833.davem@davemloft.net>
References: <1297840652-20883-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	yoshihiro.shimoda.uh@renesas.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1297840652-20883-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Wed, 16 Feb 2011 16:17:32 +0900

> This commit supports following functions.
>   - get_settings
>   - set_settings
>   - nway_reset
>   - get_msglevel
>   - set_msglevel
>   - get_link
>   - get_strings
>   - get_ethtool_stats
>   - get_sset_count
> 
> About other function, the device does not support.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Applied to net-next-2.6, thank you.
