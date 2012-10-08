From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cxgb4: allocate enough data in t4_memory_rw()
Date: Mon, 08 Oct 2012 03:13:48 -0400 (EDT)
Message-ID: <20121008.031348.53161105562769133.davem@davemloft.net>
References: <20121008071210.GA17400@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, vipul@chelsio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549Ab2JHHNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 03:13:50 -0400
In-Reply-To: <20121008071210.GA17400@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 8 Oct 2012 10:12:11 +0300

> MEMWIN0_APERTURE is the size in bytes.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.

> ---
> This was introduced in 8c357ebd569 "cxgb4: Dynamically allocate memory
> in t4_memory_rw() and get_vpd_params()" from Oct 3.

Sigh, putting bad on top of bad...
