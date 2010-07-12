From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] cxgb4 updates
Date: Sun, 11 Jul 2010 17:08:26 -0700 (PDT)
Message-ID: <20100711.170826.241449595.davem@davemloft.net>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43353
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755103Ab0GLAIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 20:08:11 -0400
In-Reply-To: <1278885679-3738-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Sun, 11 Jul 2010 15:01:14 -0700

> 
> Following is a series of 5 cxgb4 patches, all for net-next.  Mainly they
> implement the get_rxnfc, get_rxfh_indir, and set_rxfh_indir ethtool ops,
> plus a couple of fixes.

Applied patches 1-4, please fixup patch 5 to bump the register dump
version number.

Thanks.
