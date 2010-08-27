From: Anders Franzen <Anders.Franzen@ericsson.com>
Subject: Re: [PATCH 00/13] TProxy IPv6 support 2nd round
Date: Fri, 27 Aug 2010 15:22:14 +0200
Message-ID: <1282915334.5545.81.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:45321 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab0H0NS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 09:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is this patch going to get it into the kernel ever?

The patch was written by Balazs Scheidler.

The thing I realy need is part 07/13 where it implements IPv6 "local"
routing type.

I'm trying to run an LVS as an transparent loadbalanser (no VIP on the
LB) and the only way to get packets into the LVS is by policy route to 
dev lo.

Works for IPv4, but needs the patch above for IPv6.

/Anders 

