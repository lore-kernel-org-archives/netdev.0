From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add a pre-check of net_ns in sk_change_net()
Date: Mon, 10 Mar 2014 16:30:02 -0400 (EDT)
Message-ID: <20140310.163002.2203078134032583309.davem@davemloft.net>
References: <5319A3C2.8080001@cn.fujitsu.com>
	<20140309.190941.472588800498066811.davem@davemloft.net>
	<531D1C0E.6010507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guz.fnst@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531D1C0E.6010507@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Date: Mon, 10 Mar 2014 09:57:34 +0800

> We do not need to switch the net_ns if the target net_ns the same
> as the current one, so here we add a pre-check of net_ns to avoid
> this as David suggested.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>

Applied to net-next, thank you.
