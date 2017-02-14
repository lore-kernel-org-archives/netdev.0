From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hip04: Omit private ndo_get_stats function
Date: Tue, 14 Feb 2017 15:03:35 -0500 (EST)
Message-ID: <20170214.150335.1783995225231573050.davem@davemloft.net>
References: <20170214141006.11510-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdBNUDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:03:36 -0500
In-Reply-To: <20170214141006.11510-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 14 Feb 2017 15:10:06 +0100

> hip04_get_stats() just returns dev->stats so we can leave it
> out altogether and let dev_get_stats() do the job.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thank you.
