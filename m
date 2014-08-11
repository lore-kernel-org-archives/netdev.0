From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] com20020_cs: Remove typedef com20020_dev_t
Date: Mon, 11 Aug 2014 12:20:16 -0700 (PDT)
Message-ID: <20140811.122016.420002190905067268.davem@davemloft.net>
References: <20140809160718.GA15251@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140809160718.GA15251@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sat, 9 Aug 2014 21:37:18 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for
> com20020_dev_t. Also, the name of the struct is changed to drop the
> _t, to make the name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the case:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
