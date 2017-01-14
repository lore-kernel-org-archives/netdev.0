From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: use fallback for selecting txq
Date: Fri, 13 Jan 2017 20:18:30 -0500 (EST)
Message-ID: <20170113.201830.465133784845041556.davem@davemloft.net>
References: <20170113001822.GA10813@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60456 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdANBSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 20:18:36 -0500
In-Reply-To: <20170113001822.GA10813@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 12 Jan 2017 16:18:22 -0800

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Remove assignment to ndo_select_queue so that fallback is used for
> selecting txq.  Also remove the now-useless function that used to be
> assigned to ndo_select_queue.
> 
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied, thank you.
