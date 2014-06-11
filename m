From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: sxgbe: remove duplicate SXGBE_CORE_L34_ADDCTL_REG
 define
Date: Wed, 11 Jun 2014 15:01:57 -0700 (PDT)
Message-ID: <20140611.150157.537471197140401164.davem@davemloft.net>
References: <20140609150901.GC9600@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaFKWCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:02:01 -0400
In-Reply-To: <20140609150901.GC9600@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 9 Jun 2014 18:09:01 +0300

> The SXGBE_CORE_L34_ADDCTL_REG define is cut and pasted twice so we can
> delete the second instance.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
