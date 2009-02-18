From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/43] drivers/net/ixgbe: fix sparse warning: Should it
 be static?
Date: Tue, 17 Feb 2009 17:39:10 -0800 (PST)
Message-ID: <20090217.173910.117584785.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213822.24377.64757.stgit@vmbox.hanneseder.net>
	<Pine.WNT.4.64.0902152248180.31128@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754253AbZBRBj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:39:26 -0500
In-Reply-To: <Pine.WNT.4.64.0902152248180.31128@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Sun, 15 Feb 2009 22:48:51 -0800 (Pacific Standard Time)

> > Impact: Make symbol static.
> > 
> > Fix this sparse warning:
> >   drivers/net/ixgbe/ixgbe_82598.c:59:5: warning: symbol 'ixgbe_get_pcie_msix_count_82598' was not declared. Should it be static?
> > 
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> 
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
