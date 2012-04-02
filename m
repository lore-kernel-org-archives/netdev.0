From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/51] ipvs: Stop using NLA_PUT*().
Date: Mon, 02 Apr 2012 01:03:02 -0400 (EDT)
Message-ID: <20120402.010302.1302861329843358875.davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
	<1333335521-1348-22-git-send-email-davem@davemloft.net>
	<20120402050142.GA20454@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab2DBFDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 01:03:08 -0400
In-Reply-To: <20120402050142.GA20454@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 2 Apr 2012 14:01:49 +0900

> do you want me to take this patch or do you plan to take it directly?

I plan to take the whole series, otherwise I can't put the
commit in at the end that deletes these interfaces.

> Acked-by: Simon Horman <horms@verge.net.au>

Thanks.
