From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 7/7] Switch users of ipv4_devconf(_all) to
 use the pernet one
Date: Sun, 16 Dec 2007 13:32:57 -0800 (PST)
Message-ID: <20071216.133257.167542046.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ED0AA.5080106@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757843AbXLPVdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:33:10 -0500
In-Reply-To: <475ED0AA.5080106@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 21:02:18 +0300

> These are scattered over the code, but almost all the 
> "critical" places already have the proper struct net
> at hand except for snmp proc showing function and routing 
> rtnl handler.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
