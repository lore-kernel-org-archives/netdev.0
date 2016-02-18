From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] cxgb4: Use __dev_[um]c_[un]sync for MAC
 address syncing
Date: Thu, 18 Feb 2016 14:16:50 -0500 (EST)
Message-ID: <20160218.141650.1979166449206321512.davem@davemloft.net>
References: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, leedom@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946218AbcBRTQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:16:57 -0500
In-Reply-To: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 16 Feb 2016 10:07:08 +0530

> This patch series adds support to use __dev_uc_sync/__dev_mc_sync to add
> MAC address and __dev_uc_unsync/__dev_mc_unsync to delete MAC address.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
