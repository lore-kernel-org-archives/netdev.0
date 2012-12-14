From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: remove temporary variable for MLDv2 maximum
 response code computation
Date: Fri, 14 Dec 2012 13:15:53 -0500 (EST)
Message-ID: <20121214.131553.679536999744407664.davem@davemloft.net>
References: <50CAEC97.2090609@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: wcang@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab2LNSP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 13:15:56 -0500
In-Reply-To: <50CAEC97.2090609@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Date: Fri, 14 Dec 2012 17:08:39 +0800

> As suggested by Stephen Hemminger, this remove the temporary
> variable introduced in commit
> eca2a43bb0d2c6ebd528be6acb30a88435abe307
> 
> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>

Applied.

In the future, please provide the commit message header line when
referencing commits by ID, this allows to avoid ambiguity when a
commit exists in multiple trees.

I added it this time for you.

Thanks.
