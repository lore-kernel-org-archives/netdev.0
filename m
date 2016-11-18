From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] liquidio CN23XX: bitwise vs logical AND typo
Date: Fri, 18 Nov 2016 14:04:03 -0500 (EST)
Message-ID: <20161118.140403.2109023792867040848.davem@davemloft.net>
References: <20161118114734.GB3281@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbcKRTEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:04:05 -0500
In-Reply-To: <20161118114734.GB3281@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Nov 2016 14:47:35 +0300

> We obviously intended a bitwise AND here, not a logical one.
> 
> Fixes: 8c978d059224 ("liquidio CN23XX: Mailbox support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
