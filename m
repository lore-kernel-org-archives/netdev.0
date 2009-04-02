From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Series short description
Date: Thu, 02 Apr 2009 00:57:15 -0700 (PDT)
Message-ID: <20090402.005715.02030593.davem@davemloft.net>
References: <20090401060117.8641.32252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751782AbZDBH51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 03:57:27 -0400
In-Reply-To: <20090401060117.8641.32252.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Wed, 01 Apr 2009 00:16:46 -0600

> Here are the fec_mpc52xx patches which should be picked up for 2.6.29.
> Patch #1 fixes a dma related BUG_ON() discovered after the merge window
> opened.  #2 & #3 were original a single patch posted prior to the merge
> window, but not having a s-o-b line from the original author held them up.
> In the end I rewrote it from scratch as two patches just so I can get
> them merged.  #2 makes the driver use net_device_ops, and #3 fixes a NULL
> dereference.
> 
> I've tested these patches on several MPC5200 platforms.

All applied, thanks Grant.
