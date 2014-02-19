From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: ambassador: use NULL instead of 0 for pointer
Date: Wed, 19 Feb 2014 16:39:42 -0500 (EST)
Message-ID: <20140219.163942.74432949275197405.davem@davemloft.net>
References: <4982315.WAlBt88ElR@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daeseok.youn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4982315.WAlBt88ElR@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daeseok Youn <daeseok.youn@gmail.com>
Date: Wed, 19 Feb 2014 14:11:15 +0900

> From 932e928d53b1e588dc17019e7f9fa7a61b8b7468 Mon Sep 17 00:00:00 2001
> From: Daeseok Youn <daeseok.youn@gmail.com>
> Date: Wed, 19 Feb 2014 10:35:41 +0900
> Subject: [PATCH] atm: ambassador: use NULL instead of 0 for pointer
> 
> sparse says:
> 
> drivers/atm/ambassador.c:1928:24: warning:
>  Using plain integer as NULL pointer
> 
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>

Applied.
