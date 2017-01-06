From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix wrong information about
 channels reported to ethtool
Date: Fri, 06 Jan 2017 15:44:47 -0500 (EST)
Message-ID: <20170106.154447.1214120014576677138.davem@davemloft.net>
References: <20170105001850.GA20747@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754333AbdAFUot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:44:49 -0500
In-Reply-To: <20170105001850.GA20747@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 4 Jan 2017 16:18:50 -0800

> From: Weilin Chang <weilin.chang@cavium.com>
> 
> Information reported to ethtool about channels is sometimes wrong for PF,
> and always wrong for VF.  Fix them by getting the information from the
> right fields from the right structs.
> 
> Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
