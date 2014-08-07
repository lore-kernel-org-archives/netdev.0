From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Remove typedef axnet_dev_t
Date: Thu, 07 Aug 2014 16:06:59 -0700 (PDT)
Message-ID: <20140807.160659.413581430334650996.davem@davemloft.net>
References: <20140807204133.GA21448@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, paul.gortmaker@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807204133.GA21448@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 8 Aug 2014 02:11:33 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for axnet_dev_t.
> Also, the name of the struct is changed to drop the _t, to make the
> name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the case:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
