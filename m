From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Sun, 13 Apr 2008 22:46:02 -0700 (PDT)
Message-ID: <20080413.224602.116900146.davem@davemloft.net>
References: <1207839617.4311.6.camel@compaq.thuisdomein>
	<4801A85F.8090906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, jgarzik@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbYDNFqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:46:03 -0400
In-Reply-To: <4801A85F.8090906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 13 Apr 2008 08:29:51 +0200

> I guess it should return -EADDRNOTAVAIL similar to eth_mac_addr()
> when validation fails.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

