From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part7
Date: Tue, 16 Mar 2010 21:31:40 -0700 (PDT)
Message-ID: <20100316.213140.164105511.davem@davemloft.net>
References: <20100301150913.GE2799@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51608
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146Ab0CQEbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:31:18 -0400
In-Reply-To: <20100301150913.GE2799@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 1 Mar 2010 16:09:14 +0100

> 
> In mlx4, using char * to store mc address in private structure instead.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
