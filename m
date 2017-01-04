From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: remove PTP support in 23XX adapters
Date: Wed, 04 Jan 2017 13:28:55 -0500 (EST)
Message-ID: <20170104.132855.869858283382381087.davem@davemloft.net>
References: <20170103192733.GA4979@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965396AbdADS24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:28:56 -0500
In-Reply-To: <20170103192733.GA4979@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 3 Jan 2017 11:27:33 -0800

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> liquidio driver incorrectly indicates that PTP is supported in 23XX
> adapters; this patch fixes that.  PTP is supported in 66XX and 68XX
> adapters, and the driver correctly indicates that.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
