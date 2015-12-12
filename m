From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] mlxsw: core: remove an unneeded condition
Date: Fri, 11 Dec 2015 20:15:56 -0500 (EST)
Message-ID: <20151211.201556.1303183841845667915.davem@davemloft.net>
References: <20151209104129.GJ3173@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbbLLBP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:15:58 -0500
In-Reply-To: <20151209104129.GJ3173@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 9 Dec 2015 13:41:29 +0300

> We already know "err" is zero so there is no need to check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
