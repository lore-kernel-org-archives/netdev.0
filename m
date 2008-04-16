From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 0/10][VLAN]: Make VLAN devices work in net
 namespaces.
Date: Wed, 16 Apr 2008 01:02:05 -0700 (PDT)
Message-ID: <20080416.010205.264384895.davem@davemloft.net>
References: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752298AbYDPICE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 04:02:04 -0400
In-Reply-To: <4804989F.1060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 15 Apr 2008 15:59:27 +0400

> This set does not intersect with the TUN one at all, since
> they both use generic net pointers.
> 
> It also includes some changes in RTNL code to facilitate
> VLAN netnsization and a bit more VLAN cleanups.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

All applied and pushed out to net-2.6.26, thanks Pavel.
