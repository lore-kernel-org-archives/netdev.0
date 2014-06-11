From: David Miller <davem@davemloft.net>
Subject: Re: [patch] amd-xgbe: unwind on error in xgbe_mdio_register()
Date: Wed, 11 Jun 2014 15:40:47 -0700 (PDT)
Message-ID: <20140611.154047.1548691621132222113.davem@davemloft.net>
References: <20140611065626.GC16443@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbaFKWks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:40:48 -0400
In-Reply-To: <20140611065626.GC16443@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 11 Jun 2014 09:56:26 +0300

> There is a typo here so we return directly instead of unwinding.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
