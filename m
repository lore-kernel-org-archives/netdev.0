From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] drivers: net: phy: xgene: Remove redundant
 dev_err call in xgene_mdio_probe()
Date: Sat, 30 Jul 2016 20:39:23 -0700 (PDT)
Message-ID: <20160730.203923.1168981713652515625.davem@davemloft.net>
References: <1469671937-13265-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbcGaDjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 23:39:24 -0400
In-Reply-To: <1469671937-13265-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 28 Jul 2016 02:12:17 +0000

> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
