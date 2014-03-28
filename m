From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix possible memory leak on iov error
 flow
Date: Fri, 28 Mar 2014 16:18:16 -0400 (EDT)
Message-ID: <20140328.161816.327303397798614271.davem@davemloft.net>
References: <1395920797-11199-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbaC1USS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:18:18 -0400
In-Reply-To: <1395920797-11199-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 27 Mar 2014 13:46:37 +0200

> Commit 2dc33bbc4 "bnx2x: Remove the sriov VFOP mechanism" introduced a possible
> memory leak on the error flow during multicast filters configuration.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks a lot.
