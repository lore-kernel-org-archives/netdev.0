From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4 : retrieve port information from
 firmware
Date: Sun, 21 May 2017 13:30:48 -0400 (EDT)
Message-ID: <20170521.133048.1562761637839702677.davem@davemloft.net>
References: <1495196415-22234-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEURat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:30:49 -0400
In-Reply-To: <1495196415-22234-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 19 May 2017 17:50:15 +0530

> issue get port information command to firmware to retrieve port
> information and update if it is different from what was last
> recorded and also add indication for supported link modes for
> firmware port types FW_PORT_TYPE_SFP28, FW_PORT_TYPE_KR_SFP28,
> FW_PORT_TYPE_CR4_QSFP.
> 
> Based on the original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
