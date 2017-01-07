From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH] RDS: validate the requested traces user
 input against max supported
Date: Fri, 06 Jan 2017 22:14:46 -0500 (EST)
Message-ID: <20170106.221446.976636277818359983.davem@davemloft.net>
References: <1483728255-9111-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdAGDOr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:14:47 -0500
In-Reply-To: <1483728255-9111-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Fri,  6 Jan 2017 10:44:15 -0800

> Larger than supported value can lead to array read/write overflow.
> 
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied, thanks.
