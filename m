From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Fix warning while make xmldocs caused by
 dev.c
Date: Sat, 14 Feb 2015 20:35:30 -0800 (PST)
Message-ID: <20150214.203530.2227592480664407562.davem@davemloft.net>
References: <1423920394-26652-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: monis@mellanox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: standby24x7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423920394-26652-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Sat, 14 Feb 2015 22:26:34 +0900

> This patch fix following warning wile make xmldocs.
> 
>   Warning(.//net/core/dev.c:5345): No description found
>   for parameter 'bonding_info'
>   Warning(.//net/core/dev.c:5345): Excess function parameter
>   'netdev_bonding_info' description in 'netdev_bonding_info_change'
> 
> This warning starts to appear after following patch was added
> into Linus's tree during merger period.
> 
> commit 61bd3857ff2c7daf756d49b41e6277bbdaa8f789
> net/core: Add event for a change in slave state
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied.
