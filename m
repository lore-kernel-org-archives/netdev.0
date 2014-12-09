From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net : cpsw: Update Kconfig for CPSW
Date: Tue, 09 Dec 2014 13:44:33 -0500 (EST)
Message-ID: <20141209.134433.1142126041631066320.davem@davemloft.net>
References: <1417668869-25616-1-git-send-email-lokeshvutla@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux-omap@vger.kernel.org, grygorii.strashko@ti.com, balbi@ti.com,
	nsekhar@ti.com, t-kristo@ti.com
To: lokeshvutla@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbaLISof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:44:35 -0500
In-Reply-To: <1417668869-25616-1-git-send-email-lokeshvutla@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lokesh Vutla <lokeshvutla@ti.com>
Date: Thu, 4 Dec 2014 10:24:29 +0530

> CPSW is present in AM33xx, AM43xx, DRA7xx.
> Updating the Kconfig to depend on ARCH_OMAP2PLUS instead of listing
> all SoC's.
> 
> Signed-off-by: Lokesh Vutla <lokeshvutla@ti.com>

Applied to net-next, thanks.
