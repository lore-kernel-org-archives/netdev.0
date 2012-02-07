From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: remove duplicate initialization
Date: Tue, 07 Feb 2012 13:39:57 -0500 (EST)
Message-ID: <20120207.133957.864759536065326497.davem@davemloft.net>
References: <20120207072015.GB21047@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab2BGSkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:40:07 -0500
In-Reply-To: <20120207072015.GB21047@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 7 Feb 2012 10:20:15 +0300

> "priv" is initialized twice.  I kept the second one, because it is next
> to the check for NULL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
