From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: wanxl: Remove typedefs from struct names
Date: Mon, 11 Aug 2014 12:40:05 -0700 (PDT)
Message-ID: <20140811.124005.2054838849225758011.davem@davemloft.net>
References: <20140810073647.GA3684@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140810073647.GA3684@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sun, 10 Aug 2014 13:06:47 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedefs for
> port_t, card_status_t and card_t. Also, the names of the structs
> are changed to drop the _t, to make the name look less typedef-like.
> 
> The following Coccinelle semantic patch detects two cases and a
> similar one detects the case for card_t.
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied, thanks.
