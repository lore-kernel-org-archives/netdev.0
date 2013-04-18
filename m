From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qlcnic: Bug fixes
Date: Thu, 18 Apr 2013 14:55:26 -0400 (EDT)
Message-ID: <20130418.145526.1214794899892481865.davem@davemloft.net>
References: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3DRSz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:55:29 -0400
In-Reply-To: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Thu, 18 Apr 2013 14:10:03 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch series contains bug fixes for -
> * Loopback test failure while traffic is running.
> * Tx timeout and subsequent firmware reset by removing check for
>   '(adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)' from tx fast
>   path, as per Eric's suggestion.
> * Typo in logs.
> 
> Please apply to net.

Series applied, thanks.
