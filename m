From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: amd: Remove typedef local_info_t
Date: Mon, 11 Aug 2014 12:20:08 -0700 (PDT)
Message-ID: <20140811.122008.2128569135316337216.davem@davemloft.net>
References: <20140809160058.GA15164@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140809160058.GA15164@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sat, 9 Aug 2014 21:30:59 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for local_info_t.
> Also, the name of the struct is changed to drop the _t, to make the
> name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the case:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
