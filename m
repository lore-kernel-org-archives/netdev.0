From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Update connection validation for
 backplane mode
Date: Fri, 18 Nov 2016 12:28:42 -0500 (EST)
Message-ID: <20161118.122842.450611488209425444.davem@davemloft.net>
References: <20161117144337.5714.57761.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752559AbcKRR2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 12:28:44 -0500
In-Reply-To: <20161117144337.5714.57761.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 17 Nov 2016 08:43:37 -0600

> Update the connection type enumeration for backplane mode and return
> an error when there is a mismatch between the mode and the connection
> type.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
