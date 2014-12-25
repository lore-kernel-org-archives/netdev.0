From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: change error message to debug message in
 __bond_release_one()
Date: Thu, 25 Dec 2014 18:29:22 -0500 (EST)
Message-ID: <20141225.182922.501821863388146322.davem@davemloft.net>
References: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	dingtianhong@huawei.com
To: wen.gang.wang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbaLYX3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 18:29:24 -0500
In-Reply-To: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wengang Wang <wen.gang.wang@oracle.com>
Date: Tue, 23 Dec 2014 09:24:36 +0800

> In __bond_release_one(), when the interface is not a slave or not a slave of
> "this" master, it log error message.
> 
> The message actually should be a debug message matching what bond_enslave()
> does.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

Applied, thanks.
