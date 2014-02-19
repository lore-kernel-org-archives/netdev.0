From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: nicstar: use NULL instead of 0 for pointer
Date: Wed, 19 Feb 2014 16:39:47 -0500 (EST)
Message-ID: <20140219.163947.1811017443430580104.davem@davemloft.net>
References: <1738246.bUPoQjSxLC@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daeseok.youn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1738246.bUPoQjSxLC@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daeseok Youn <daeseok.youn@gmail.com>
Date: Wed, 19 Feb 2014 14:12:46 +0900

> From c320d2ea1ed51c88255c33a50c74fa3598ab7be6 Mon Sep 17 00:00:00 2001
> From: Daeseok Youn <daeseok.youn@gmail.com>
> Date: Wed, 19 Feb 2014 10:10:11 +0900
> Subject: [PATCH] atm: nicstar: use NULL instead of 0 for pointer
> 
> sparse says:
> 
> drivers/atm/nicstar.c:642:27: warning:
>  Using plain integer as NULL pointer
> drivers/atm/nicstar.c:644:27:
>  warning: Using plain integer as NULL pointer
> drivers/atm/nicstar.c:982:51:
>  warning: Using plain integer as NULL pointer
> drivers/atm/nicstar.c:996:51:
>  warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>

Applied.
