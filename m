From: David Miller <davem@davemloft.net>
Subject: Re: net 00/06: add GARP/GVRP support
Date: Sat, 05 Jul 2008 21:33:47 -0700 (PDT)
Message-ID: <20080705.213347.114507391.davem@davemloft.net>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbYGFEdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 00:33:47 -0400
In-Reply-To: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu,  3 Jul 2008 19:04:41 +0200 (MEST)

> These patches add an implementation of the GARP (Generic Attribute
> Registration Protocol) applicant-only participant, which can be used
> to dynamically register VLANs and multicast addresses with switches.
> Applicant-only means it can only be used as a client, not on a bridge.
> Also included is a GVRP (GARP VLAN Registration Protocol) application
> on top.

These look good, applied and pushed out to net-next-2.6, thanks!
