From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Sat, 28 Apr 2007 20:47:54 -0700 (PDT)
Message-ID: <20070428.204754.62343452.davem@davemloft.net>
References: <20070427145508.9c5641a2.sfr@canb.auug.org.au>
	<4633689E.50900@garzik.org>
	<20070429114446.31f40a30.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, paulus@samba.org, akpm@linux-foundation.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754543AbXD2Drp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 23:47:45 -0400
In-Reply-To: <20070429114446.31f40a30.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sun, 29 Apr 2007 11:44:46 +1000

> So can I take this as a future OK for architecture specific network
> drivers changes to go through the architecture trees (cc'd to you)?

It's been my experience that if I'm just working through some
platform or bus specific API changes, people like Jeff tend to
not mind if it goes via ARCH trees and the like.
