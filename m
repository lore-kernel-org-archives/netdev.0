From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: Remove return from a void function
Date: Thu, 23 Feb 2017 10:55:20 -0500 (EST)
Message-ID: <20170223.105520.2000366361012988099.davem@davemloft.net>
References: <1487838169-26207-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbdBWPzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:55:33 -0500
In-Reply-To: <1487838169-26207-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Thu, 23 Feb 2017 03:22:49 -0500

> In a void function, it is not necessary to append a return statement in it.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied.
