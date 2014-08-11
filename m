From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atmel: Remove typedef atmel_priv_ioctl
Date: Mon, 11 Aug 2014 12:20:25 -0700 (PDT)
Message-ID: <20140811.122025.1493857112088523823.davem@davemloft.net>
References: <20140809162220.GA18091@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@thekelleys.org.uk, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140809162220.GA18091@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sat, 9 Aug 2014 21:52:20 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for
> atmel_priv_ioctl. 
> 
> The following Coccinelle semantic patch detects the case:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
