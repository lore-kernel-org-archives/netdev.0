From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix bad merge conflict resolution
Date: Thu, 05 Sep 2013 22:58:17 -0400 (EDT)
Message-ID: <20130905.225817.700066425182547791.davem@davemloft.net>
References: <20130905.163725.106795517693348522.davem@davemloft.net>
	<1378429301-19964-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org
To: olof@lixom.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378429301-19964-1-git-send-email-olof@lixom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu,  5 Sep 2013 18:01:41 -0700

> Merge commit 06c54055bebf919249aa1eb68312887c3cfe77b4 did a bad conflict
> resolution accidentally leaving out a closing brace. Add it back.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> ---
> 
> This breaks a handful of defconfigs on ARM, so it'd be good to see it
> applied pretty quickly. Thanks!

Looks like Linus applied this, thanks Olof.
