From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Increase max number of tc u32 links
Date: Thu, 16 Feb 2017 14:33:06 -0500 (EST)
Message-ID: <20170216.143306.1875271007182153259.davem@davemloft.net>
References: <1487227965-29381-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com,
        rahul.lakkireddy@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932694AbdBPTdI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 14:33:08 -0500
In-Reply-To: <1487227965-29381-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu, 16 Feb 2017 12:22:45 +0530

> From: Arjun V <arjun@chelsio.com>
> 
> Make max number of supported tc u32 links equal to max number of filters
> supported by hardware.
> 
> Signed-off-by: Arjun V <arjun@chelsio.com>
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
