From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hdlc: Remove typedefs from struct names
Date: Mon, 11 Aug 2014 12:20:45 -0700 (PDT)
Message-ID: <20140811.122045.1648179759087421559.davem@davemloft.net>
References: <20140809164716.GA21548@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140809164716.GA21548@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sat, 9 Aug 2014 22:17:16 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedefs for
> fr_hdr and pvc_device. Also, the names of the structs are changed to
> drop the _t, to make the name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the case fr_hdr and a
> similar one detects the case for pvc_device.
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
