From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Handle different key sizes between address
 families in flow cache
Date: Fri, 16 Sep 2011 18:57:37 -0400 (EDT)
Message-ID: <20110916.185737.1102041103930104119.davem@davemloft.net>
References: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
	<1315141641-3120-3-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454Ab1IPW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 18:57:47 -0400
In-Reply-To: <1315141641-3120-3-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 4 Sep 2011 09:07:21 -0400

> With the conversion of struct flowi to a union of AF-specific structs, some
> operations on the flow cache need to account for the exact size of the key.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied.
