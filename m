From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/netlabel: copy and paste bug in
 netlbl_cfg_unlbl_map_add()
Date: Fri, 25 Nov 2011 01:42:36 -0500 (EST)
Message-ID: <20111125.014236.1962174838825919249.davem@davemloft.net>
References: <20111124071820.GB14122@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab1KYGmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 01:42:43 -0500
In-Reply-To: <20111124071820.GB14122@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2011 10:18:20 +0300

> This was copy and pasted from the IPv4 code.  We're calling the
> ip4 version of that function and map4 is NULL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
