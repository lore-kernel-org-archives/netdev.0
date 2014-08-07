From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: ethernet: Remove typedef for struct and
 enum
Date: Thu, 07 Aug 2014 16:06:42 -0700 (PDT)
Message-ID: <20140807.160642.1780454276654586342.davem@davemloft.net>
References: <20140807203915.GA21337@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, w-lkml@lebenslange-mailadresse.de,
	balbi@ti.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807203915.GA21337@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 8 Aug 2014 02:09:16 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure and enum types. This patch gets rid of the typedef for
> cardtype_t and local_info_t. Also, the names of the struct and enum
> are changed to drop the _t, to make the name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the case for struct type:
...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
