From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET/PHY: Eliminate the forced speed reduction
 algorithm.
Date: Tue, 19 Feb 2013 13:19:14 -0500 (EST)
Message-ID: <20130219.131914.578123633760866734.davem@davemloft.net>
References: <1361267628.4919.6.camel@kkk.nita.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: kapranoff@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361267628.4919.6.camel@kkk.nita.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Kapranov <kapranoff@inbox.ru>
Date: Tue, 19 Feb 2013 13:53:48 +0400

> Tested at 2.6.38.7, applicable up to for 3.0.4. 
> Signed-off-by: Kirill Kapranov <kkk@nita.ru>,<kapranoff@inbox.ru>
>  --- linux/drivers/net/phy/phy.c.orig	2011-05-22 02:13:59.000000000 +0400
> +++ linux/drivers/net/phy/phy.c	2012-04-28 12:49:37.000000000 +0400

Your patches are continually poorly formatted, and corrupted by
your email client, which means that the patches cannot be applied
properly and all of our automated tools for patch tracking do not
recognize your submissions as a patch.
