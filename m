From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Fri, 21 Feb 2014 12:14:36 -0500 (EST)
Message-ID: <20140221.121436.508104819618605416.davem@davemloft.net>
References: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
	<20140219.164243.2046477353509124098.davem@davemloft.net>
	<BF3270C86E8B1349A26C34E4EC1C44CB2C87E699@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbaBUROk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 12:14:40 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C87E699@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Fri, 21 Feb 2014 10:28:24 +0000

> There is no option for --set-rxfh-indir to reset the indirection table.

But this can be easily added to ethtool.

My point is that the intention is _clearly_ there to provide this
facility.
