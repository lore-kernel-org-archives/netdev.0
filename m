From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/3com: Make el3_netdev_get_ecmd return void
Date: Mon, 05 Jun 2017 11:01:36 -0400 (EDT)
Message-ID: <20170605.110136.1631431314139992722.davem@davemloft.net>
References: <20170604172446.4294-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, tremyfr@gmail.com, dhowells@redhat.com,
        netdev@vger.kernel.org
To: yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdFEPBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 11:01:38 -0400
In-Reply-To: <20170604172446.4294-1-yuval.shaia@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Sun,  4 Jun 2017 20:24:46 +0300

> Make return value void since function never returns meaningfull value.
> 
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>

Applied to net-next.
