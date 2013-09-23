From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] mrp: add periodictimer to allow retries when
 packets get lost
Date: Mon, 23 Sep 2013 16:54:07 -0400 (EDT)
Message-ID: <20130923.165407.372933292995681502.davem@davemloft.net>
References: <1379532280-11047-1-git-send-email-noel@burton-krahn.com>
	<20130920.145903.1454447110808820874.davem@davemloft.net>
	<523CF71D.3090002@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noel@burton-krahn.com, netdev@vger.kernel.org, joe@perches.com
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab3IWUyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 16:54:09 -0400
In-Reply-To: <523CF71D.3090002@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Date: Fri, 20 Sep 2013 21:32:13 -0400

> Noel, thanks for your patch. This timer was apparently not in the GARP
> standard but added in the MRP standard and I missed it. Looks good to
> me.
> 
> Acked-by: David Ward <david.ward@ll.mit.edu>

Applied, thanks everyone.
