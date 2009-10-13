From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Tue, 13 Oct 2009 03:45:32 -0700 (PDT)
Message-ID: <20091013.034532.36362276.davem@davemloft.net>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw>
	<4ACD585B.5080106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas@wytron.com.tw, netdev@vger.kernel.org,
	thierry.reding@avionic-design.de, nios2-dev@sopc.et.ntust.edu.tw,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759450AbZJMKph@vger.kernel.org>
In-Reply-To: <4ACD585B.5080106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2009 05:11:23 +0200

> [PATCH] net: Add netdev_alloc_skb_ip_align() helper
> 
> Instead of hardcoding NET_IP_ALIGN stuff in various network drivers, we can
> add a helper around netdev_alloc_skb()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
