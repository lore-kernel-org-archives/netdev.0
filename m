From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [trivial] net: Fix warning on make htmldocs caused by
 skbuff.c
Date: Tue, 28 Jan 2014 18:06:23 -0800 (PST)
Message-ID: <20140128.180623.2101072474797169949.davem@davemloft.net>
References: <1390925128-20768-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: standby24x7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390925128-20768-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Wed, 29 Jan 2014 01:05:28 +0900

> This patch fixed following Warning while executing "make htmldocs".
> 
> Warning(/net/core/skbuff.c:2164): No description found for parameter 'from'
> Warning(/net/core/skbuff.c:2164): Excess function parameter 'source'
> description in 'skb_zerocopy'
> Replace "@source" with "@from" fixed the warning.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied, thank you.
