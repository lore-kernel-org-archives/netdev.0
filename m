From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: solos-pci: make solos_bh() as static
Date: Wed, 19 Feb 2014 16:39:53 -0500 (EST)
Message-ID: <20140219.163953.1781109081917971221.davem@davemloft.net>
References: <1547067.MtNWZjBp8J@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daeseok.youn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1547067.MtNWZjBp8J@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daeseok Youn <daeseok.youn@gmail.com>
Date: Wed, 19 Feb 2014 14:13:54 +0900

> From 6297aabeff748777b520cc0ee835af0a3ddc79e2 Mon Sep 17 00:00:00 2001
> From: Daeseok Youn <daeseok.youn@gmail.com>
> Date: Wed, 19 Feb 2014 10:49:12 +0900
> Subject: [PATCH] atm: solos-pci: make solos_bh() as static
> 
> sparse says:
> 
> drivers/atm/solos-pci.c:763:6: warning:
>  symbol 'solos_bh' was not declared. Should it be static?
> 
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>

Applied.
