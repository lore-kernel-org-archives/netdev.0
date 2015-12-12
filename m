From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] mlxsw: spectrum: fix some error handling
Date: Fri, 11 Dec 2015 20:15:51 -0500 (EST)
Message-ID: <20151211.201551.1725224415474409711.davem@davemloft.net>
References: <20151209103351.GI3173@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbLLBPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:15:53 -0500
In-Reply-To: <20151209103351.GI3173@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 9 Dec 2015 13:33:51 +0300

> The "err = " assignment is missing here.
> 
> Fixes: 0d65fc13042f ('mlxsw: spectrum: Implement LAG port join/leave')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
