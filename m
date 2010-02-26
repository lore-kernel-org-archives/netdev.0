From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part5 V2
Date: Fri, 26 Feb 2010 01:49:53 -0800 (PST)
Message-ID: <20100226.014953.203661752.davem@davemloft.net>
References: <20100223191948.GE2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935768Ab0BZJtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:49:35 -0500
In-Reply-To: <20100223191948.GE2673@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 23 Feb 2010 20:19:49 +0100

> removed some needless checks and also corrected bug in lp486e (dmi was passed
> instead of dmi->dmi_addr)
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
