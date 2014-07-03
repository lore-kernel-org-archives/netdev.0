From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qlcnic: Enhance Tx timeout debug data
 collection.
Date: Wed, 02 Jul 2014 17:11:27 -0700 (PDT)
Message-ID: <20140702.171127.552804575089857863.davem@davemloft.net>
References: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGCAL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 20:11:28 -0400
In-Reply-To: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Fri, 27 Jun 2014 19:01:37 -0400

> The following set of patches are for enhancing Tx timeout debug collection
> 
> - Collect a firmware dump on first Tx timeout if netif_msg_tx_err() is set
> - Log Receive and Status ring info on Tx timeout, in addition to Tx ring info
> - Log additional Tx ring info if netif_msg_tx_err() is set
> - Update driver version to 5.3.61
> 
> Please apply this series to net-next.

Series applied, thanks.
