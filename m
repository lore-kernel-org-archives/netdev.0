From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Sun, 28 Feb 2010 01:44:20 -0800 (PST)
Message-ID: <20100228.014420.258117097.davem@davemloft.net>
References: <20100227173543.GA6550@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031694Ab0B1JoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:44:02 -0500
In-Reply-To: <20100227173543.GA6550@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 27 Feb 2010 18:35:45 +0100

> 
> also added missed locking in rndis_wlan.c
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.
