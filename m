From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Remove typedef board_info_t
Date: Thu, 07 Aug 2014 16:05:32 -0700 (PDT)
Message-ID: <20140807.160532.655009033527959008.davem@davemloft.net>
References: <20140807191814.GA20351@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.ruder@elecsyscorp.com, joe@perches.com, Baohua.Song@csr.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807191814.GA20351@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 8 Aug 2014 00:48:14 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for board_info_t.
> Also, the name of the structs is changed to drop the _t, to make the
> name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the cases:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
