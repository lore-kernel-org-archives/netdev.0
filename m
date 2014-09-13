From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: in
 suspend/resume bring down/up all the netdev
Date: Sat, 13 Sep 2014 13:01:08 -0400 (EDT)
Message-ID: <20140913.130108.918693454766007342.davem@davemloft.net>
References: <1410456158-6215-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaIMRBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 13:01:10 -0400
In-Reply-To: <1410456158-6215-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 11 Sep 2014 22:52:38 +0530

> During suspend and resume in Dual EMAC, second port is not working as in
> suspend/resume only the first slave netdev is closed and opened. So bring
> down and up all the interfaces that are up during suspend/resume.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Tested-by: Nishanth Menon <nm@ti.com>

Applied, thanks.
