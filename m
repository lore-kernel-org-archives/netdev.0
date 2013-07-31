From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx5: fix error return code in mlx5_alloc_uuars()
Date: Tue, 30 Jul 2013 19:34:02 -0700 (PDT)
Message-ID: <20130730.193402.158391859266321153.davem@davemloft.net>
References: <CAPgLHd-BWzEPhH=Otzyc5p-MEm7MXQNvEPTyYhRLzq4d=FT2tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758875Ab3GaCeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:34:03 -0400
In-Reply-To: <CAPgLHd-BWzEPhH=Otzyc5p-MEm7MXQNvEPTyYhRLzq4d=FT2tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 30 Jul 2013 07:57:06 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENOMEM from the ioremap error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
