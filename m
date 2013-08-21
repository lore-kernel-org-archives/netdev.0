From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: remove platform data
 header file of cpsw
Date: Tue, 20 Aug 2013 23:50:38 -0700 (PDT)
Message-ID: <20130820.235038.1393932767512291651.davem@davemloft.net>
References: <1376914660-20431-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab3HUGuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:50:39 -0400
In-Reply-To: <1376914660-20431-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 19 Aug 2013 17:47:40 +0530

> CPSW driver no longer supports platform register as all the SoCs which has CPSW
> are supporting DT only booting, so moving cpsw.h header file from platform
> include to drivers/net/ethernet/ti
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied.
