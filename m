From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 16:49:52 -0700 (PDT)
Message-ID: <20090917.164952.33104590.davem@davemloft.net>
References: <20090916.204801.190052862.davem@davemloft.net>
	<C43529A246480145B0A6D0234BDB0F0DE8A1@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org, Charles.Li@Micrel.Com,
	Choi@kroah.com, jgarzik@redhat.com, shemminger@vyatta.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753662AbZIQXtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 19:49:35 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0DE8A1@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Thu, 17 Sep 2009 12:30:27 -0700

> --- linux-2.6.31-rc3/drivers/net/ks8851_mll.c.orig	2009-09-17
> 10:18:56.000000000 -0700
> +++ linux-2.6.31-rc3/drivers/net/ks8851_mll.c	2009-09-17
> 10:09:37.000000000 -0700
> @@ -21,8 +21,6 @@
>   * KS8851 16bit MLL chip from Micrel Inc.

I can't use this patch or even test it, as your email client
has corrupted it by, for example, breaking up long lines.
