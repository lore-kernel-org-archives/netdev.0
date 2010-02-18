From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] smsc911x: convert to use
 netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 15:01:48 -0800 (PST)
Message-ID: <20100218.150148.00385695.davem@davemloft.net>
References: <20100218092238.GD2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387Ab0BRXBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:01:32 -0500
In-Reply-To: <20100218092238.GD2772@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 18 Feb 2010 10:22:38 +0100

> also removed unnecessary checks
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
