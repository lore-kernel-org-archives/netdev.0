From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: Fix warning while make xmldocs caused by
 skbuff.c
Date: Tue, 25 Aug 2015 14:21:19 -0700 (PDT)
Message-ID: <20150825.142119.1984045622358159031.davem@davemloft.net>
References: <1440424614-471-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	corbet@lwn.net, linux-media@vger.kernel.org
To: standby24x7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440424614-471-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Mon, 24 Aug 2015 22:56:54 +0900

> This patch fix following warnings.
> 
> .//net/core/skbuff.c:407: warning: No description found
> for parameter 'len'
> .//net/core/skbuff.c:407: warning: Excess function parameter
>  'length' description in '__netdev_alloc_skb'
> .//net/core/skbuff.c:476: warning: No description found
>  for parameter 'len'
> .//net/core/skbuff.c:476: warning: Excess function parameter
> 'length' description in '__napi_alloc_skb'
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied, thank you.
