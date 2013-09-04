From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: NAPI requires netif_receive_skb()
Date: Wed, 04 Sep 2013 14:12:52 -0400 (EDT)
Message-ID: <20130904.141252.532474080722830977.davem@davemloft.net>
References: <201309030303.11381.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201309030303.11381.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 3 Sep 2013 03:03:10 +0400

> Driver supporting NAPI should use NAPI-specific function for receiving packets,
> so netif_rx() should be changed to netif_receive_skb().
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
