From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] net: sxgbe: fix logical vs bitwise operation
Date: Tue, 01 Apr 2014 16:27:39 -0400 (EDT)
Message-ID: <20140401.162739.945883984370804455.davem@davemloft.net>
References: <20140401133900.GB11536@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbaDAU1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:41 -0400
In-Reply-To: <20140401133900.GB11536@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 1 Apr 2014 16:39:00 +0300

> Bitwise '|' was intended here instead of logical '||'.
> 
> Fixes: 1edb9ca69e8a ('net: sxgbe: add basic framework for Samsung 10Gb ethernet driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
