From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 14:38:49 -0700 (PDT)
Message-ID: <20071005.143849.115921503.davem@davemloft.net>
References: <20071005084036.52dc943c@freepuppy.rosehill>
	<20071005.141217.41646184.davem@davemloft.net>
	<4706A937.3060304@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbXJEViu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:38:50 -0400
In-Reply-To: <4706A937.3060304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 05 Oct 2007 17:14:31 -0400

> You just have to ignore some of its complaints.  Part of my coding style 
> includes the multiple assignment thing that checkpatch complains about:
> 
> 	status =
> 	msi->status = br32(QDMA_STAT);
> 
> and I am not going to stop doing that just because checkpatch complains :)

Whilst I wouldn't condone this practice personally, I fail to
see a reason to prevent someone willing to write and maintain
a 10,000 line driver from doing so :-)
