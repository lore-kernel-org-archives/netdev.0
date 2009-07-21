From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macsonic, jazzsonic - fix oops on module unload
Date: Tue, 21 Jul 2009 12:22:00 -0700 (PDT)
Message-ID: <20090721.122200.83947448.davem@davemloft.net>
References: <1247345591-22643-20-git-send-email-u.kleine-koenig@pengutronix.de>
	<alpine.OSX.2.00.0907220032230.796@silk.local>
	<alpine.OSX.2.00.0907220119060.796@silk.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de,
	u.kleine-koenig@pengutronix.de
To: fthain@telegraphics.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755973AbZGUTVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 15:21:54 -0400
In-Reply-To: <alpine.OSX.2.00.0907220119060.796@silk.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Finn Thain <fthain@telegraphics.com.au>
Date: Wed, 22 Jul 2009 01:40:02 +1000 (EST)

> 
> Set the driver data before using it. Fixes an oops when doing rmmod.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Applied, thanks.
