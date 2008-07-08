From: David Miller <davem@davemloft.net>
Subject: Re: vlan 00/07: VLAN update part 1
Date: Tue, 08 Jul 2008 03:44:38 -0700 (PDT)
Message-ID: <20080708.034438.180062433.davem@davemloft.net>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753939AbYGHKoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:44:38 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon,  7 Jul 2008 14:35:58 +0200 (MEST)

> following is a first VLAN update for net-next-2.6, containing a fix for the
> skb->network_header issue pointed out by Lennert, VLAN ethtool support for
> querying offload settings, uninlining of __vlan_hwaccel_rx and some assorted
> cleanups.
> 
> A second update in my queue on top of this one will attack the packet socket
> inconsistencies with VLAN acceleration, but I've split the set for easier
> review of the more interesting changes.
> 
> Please apply, thanks.

Looks good.  Applied and pushed out to net-next-2.6

Thanks!
