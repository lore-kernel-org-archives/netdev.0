From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] staging: convert to use
 netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 15:02:09 -0800 (PST)
Message-ID: <20100218.150209.185509613.davem@davemloft.net>
References: <20100218151014.GJ2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751702Ab0BRXBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:01:53 -0500
In-Reply-To: <20100218151014.GJ2772@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 18 Feb 2010 16:10:14 +0100

> removed needless checks in arlan-main.c and slicoss.c
> fixed bug in et131x_netdev.c to actually fill addresses in.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
