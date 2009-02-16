From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 24/43] drivers/net/ixgbe: fix sparse warning: Should it
 be	static?
Date: Sun, 15 Feb 2009 22:48:51 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0902152248180.31128@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
 <20090214213822.24377.64757.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64484 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbZBPGs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 01:48:58 -0500
In-Reply-To: <20090214213822.24377.64757.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Impact: Make symbol static.
> 
> Fix this sparse warning:
>   drivers/net/ixgbe/ixgbe_82598.c:59:5: warning: symbol 'ixgbe_get_pcie_msix_count_82598' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
