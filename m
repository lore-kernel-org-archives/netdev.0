From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Add DRA7xx and AM43xx platform support in
 cpsw-phy-sel driver
Date: Tue, 13 May 2014 00:11:45 -0400 (EDT)
Message-ID: <20140513.001145.2034679814844372739.davem@davemloft.net>
References: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaEMELr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:11:47 -0400
In-Reply-To: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 9 May 2014 19:07:32 +0530

> Adding DRA7xx and AM43xx platform support to cpsw-phy-sel driver to select
> phy mode in control driver and fixing the uninitialized dev by initializing
> to platform device structure pointer.
> 
> Changes from Initial version
> * Added back the missing patch (1/3)

Series applied to net-next, thanks.
