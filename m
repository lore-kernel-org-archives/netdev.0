From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP
 traffic
Date: Mon, 30 Jul 2007 15:43:32 -0700 (PDT)
Message-ID: <20070730.154332.72713181.davem@davemloft.net>
References: <200707301724.33865.ossthema@de.ibm.com>
	<46AE0F36.8030605@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com, gallatin@myri.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34830
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbXG3Wng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 18:43:36 -0400
In-Reply-To: <46AE0F36.8030605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 30 Jul 2007 12:17:58 -0400

> David, thoughts on merging?  I'm not We could stick this into your tree 
> or mine.  Whether yours or mine, I would like to keep the driver and 
> net-core patches together in the same git tree.

No objections and I'll stick it into my net-2.6.24 tree once I cut
that, I'll have the NAPI stuff in there too so I'll keep these two
merge nightmares out of your hair :-)

