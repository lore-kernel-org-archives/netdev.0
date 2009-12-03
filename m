From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] llc enhancements
Date: Thu, 03 Dec 2009 15:55:53 -0800 (PST)
Message-ID: <20091203.155553.236357128.davem@davemloft.net>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754855AbZLCXzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:55:47 -0500
In-Reply-To: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri,  4 Dec 2009 00:31:34 +0200

> 
> This patch series introduces a couple of general enhancements to LLC
> socket code as well as changes to scale the LLC socket lookup code for
> a large number of interfaces needed for our uses cases (STP traffic
> generation from a large number of ports, via virtual network
> interfaces).

These patches are still in flux, in particular the hash table
bits need changes, so this stuff will have to wait until the
next merge window, it's too late for the current one sorry.
