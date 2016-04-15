From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tipc: improvements to the link setup
 algorithm
Date: Fri, 15 Apr 2016 16:10:59 -0400 (EDT)
Message-ID: <20160415.161059.1767181927317431918.davem@davemloft.net>
References: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcDOULC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 16:11:02 -0400
In-Reply-To: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 15 Apr 2016 13:33:02 -0400

> This series addresses some smaller issues regarding the link setup 
> algorithm. The first commit fixes a rare bug we have discovered during
> testing; the second one may have some future impact on cluster 
> scalabilty, while remaining ones can be regarded as cosmetic in
> a wider sense of the word.

Series applied, thanks.
