From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lpc_eth: remove obsolete ifdefs
Date: Wed, 08 Aug 2012 16:08:04 -0700 (PDT)
Message-ID: <20120808.160804.27739743623506268.davem@davemloft.net>
References: <1344431934-16748-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, aletes.xgr@gmail.com, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com
To: stigge@antcom.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344431934-16748-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Stigge <stigge@antcom.de>
Date: Wed,  8 Aug 2012 15:18:54 +0200

> The #ifdefs regarding CONFIG_ARCH_LPC32XX_MII_SUPPORT and
> CONFIG_ARCH_LPC32XX_IRAM_FOR_NET are obsolete since the symbols have been
> removed from Kconfig and replaced by devicetree based configuration.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>

Applied, thanks.
