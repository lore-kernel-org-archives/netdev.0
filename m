From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] dccp: Feature negotiation - conclusion of Part II
 (core)
Date: Mon, 01 Dec 2008 23:34:48 -0800 (PST)
Message-ID: <20081201.233448.32813569.davem@davemloft.net>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228051376-8174-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750845AbYLBHes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 02:34:48 -0500
In-Reply-To: <1228051376-8174-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 30 Nov 2008 14:22:50 +0100

> Patch #1: Continues where the previous patch set left off, by adding
>           the insertion of feature-negotiation options onto the skb.
> Patch #2: Completes the insertion of featneg options.
> Patch #3: Logic/algorithm to actually reconcile negotiation options.
> Patch #4: Receiver support to process incoming Change L/R options. 
> Patch #5: Receiver support to process incoming Confirm R/L options.
> Patch #6: Handlers for activating successfully negotiated features.

Looks fine enough, all applied to net-next-2.6, thanks Gerrit.
