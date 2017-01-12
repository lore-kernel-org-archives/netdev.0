From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio VF: reduce load time of module
Date: Thu, 12 Jan 2017 15:53:15 -0500 (EST)
Message-ID: <20170112.155315.1053860489087854422.davem@davemloft.net>
References: <20170112014027.GA9704@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdALVB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:01:57 -0500
In-Reply-To: <20170112014027.GA9704@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 11 Jan 2017 17:40:27 -0800

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Reduce the load time of the VF driver by decreasing the wait time between
> iterations of the loop that polls for a mailbox response from the PF. Also
> change the wait time units from jiffies to milliseconds.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied, thanks.
