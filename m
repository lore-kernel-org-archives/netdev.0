From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: move debugging code before the return
Date: Thu, 10 Jan 2013 14:39:08 -0800 (PST)
Message-ID: <20130110.143908.2290964096217827110.davem@davemloft.net>
References: <20130110085807.GB23063@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab3AJWjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:39:09 -0500
In-Reply-To: <20130110085807.GB23063@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 10 Jan 2013 11:58:07 +0300

> I move the return down a line after the debugging printk.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
