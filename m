From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - REPOST] asix.c - Add support for AX88772A devices -
Date: Wed, 14 Jan 2009 21:21:15 -0800 (PST)
Message-ID: <20090114.212115.104189191.davem@davemloft.net>
References: <1231949520.4105.97.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753306AbZAOFVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:21:14 -0500
In-Reply-To: <1231949520.4105.97.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Wed, 14 Jan 2009 11:12:00 -0500

> 
> The attached patch adds support for ASIX AX88772A devices, which is used
> in some netbooks, notebooks and embedded devices.  It's largely
> compatible with the AX88772 family.
> 
> This re-post does not include changes to the ax88772_link_reset()
> function that removed the use of the generic MII calls in favor of more
> explicit register reads.  Those changes were not required for AX88772A
> support.
> 
> Thanks to Louis <louis@asix.com.tw> for the initial patch.
> 
> Signed-off-by: David Hollis <dhollis@davehollis.com>

Applied, thanks.
