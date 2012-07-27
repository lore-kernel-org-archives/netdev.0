From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-07-27
Date: Fri, 27 Jul 2012 14:26:41 -0700 (PDT)
Message-ID: <20120727.142641.1758613016734325267.davem@davemloft.net>
References: <20120727155806.GB6110@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120727155806.GB6110@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 27 Jul 2012 11:58:06 -0400

> These fixes are intended for the 3.6 stream.
> 
> Hauke Mehrtens provides a pair of bcma fixes, one to fix a build
> regression on mips and another to correct a pair of missing iounmap
> calls.
> 
> Thomas Huehn offers a mac80211_hwsim fix to avoid a possible
> use-after-free bug.
> 
> Please let me know if there are problems!

Pulled, thanks John.
