From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] tulip: convert to use
 netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 15:01:59 -0800 (PST)
Message-ID: <20100218.150159.145025301.davem@davemloft.net>
References: <20100218133453.GH2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org, kyle@mcmartin.ca
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592Ab0BRXBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:01:43 -0500
In-Reply-To: <20100218133453.GH2772@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 18 Feb 2010 14:34:54 +0100

> also bug in de2104x.c was corrected:
> for (i = 0; i < 32; i++) loop should be outside mc_list iteration.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
