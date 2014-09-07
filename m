From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe-phy: Fix build break for missing
 declaration
Date: Sun, 07 Sep 2014 11:21:53 -0700 (PDT)
Message-ID: <20140907.112153.36211165333072281.davem@davemloft.net>
References: <20140907145441.7257.26465.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbaIGSV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 14:21:57 -0400
In-Reply-To: <20140907145441.7257.26465.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Sun, 7 Sep 2014 09:54:41 -0500

> A previous patch inadvertently deleted a declaration in the
> amd_xgbe_an_tx_training function causing the build to fail.
> 
> Add the declaration for 'priv' back to the function.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
