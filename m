From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use nla_get_in_addr and nla_put_in_addr for
 ipv4 address
Date: Sat, 02 Apr 2016 20:16:19 -0400 (EDT)
Message-ID: <20160402.201619.815067577114161868.davem@davemloft.net>
References: <1459419698-4466-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459419698-4466-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Thu, 31 Mar 2016 18:21:38 +0800

> Since nla_get_in_addr and nla_put_in_addr were implemented,
> so use them appropriately.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied, thank you.
