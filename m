From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net-next:asix: update VERSION and white space
 changes
Date: Mon, 14 Nov 2011 18:42:40 -0500 (EST)
Message-ID: <20111114.184240.1832866874941847383.davem@davemloft.net>
References: <1321312921-7748-1-git-send-email-grundler@chromium.org>
	<1321312921-7748-5-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321312921-7748-5-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Mon, 14 Nov 2011 15:22:01 -0800

> No functional changes. Three things targeted:
> o update VERSION to reflect previous changes.
> o fix up white space/formatting of some lines
> o define 150 to be AX_SWRESET_MDELAY (self documenting code)
> 
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Why have such a wonderful set of real bug fixes that I can apply right
now and send off to Linus's tree, only to sabotage it with whitespace
changes at the end which are no appropriate?

Please, just submit this without the whitespace and other cleanup
stuff.  Restrict it to real bug fixes, and I'll push it around.

The whitespace and other bits can be submitted for net-next afterwards.
