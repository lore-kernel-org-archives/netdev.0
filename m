From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Align AF-specific flowi structs to long
Date: Fri, 16 Sep 2011 18:57:31 -0400 (EDT)
Message-ID: <20110916.185731.1683344574880024034.davem@davemloft.net>
References: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
	<1315141641-3120-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454Ab1IPW5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 18:57:45 -0400
In-Reply-To: <1315141641-3120-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 4 Sep 2011 09:07:20 -0400

> AF-specific flowi structs are now passed to flow_key_compare, which must
> also be aligned to a long.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied.
