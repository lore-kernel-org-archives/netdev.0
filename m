From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/8] liquidio: adding support for ethtool
 --set-ring feature
Date: Mon, 14 Aug 2017 22:21:56 -0700 (PDT)
Message-ID: <20170814.222156.501253374258719071.davem@davemloft.net>
References: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751509AbdHOFV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:21:57 -0400
In-Reply-To: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 14 Aug 2017 12:00:34 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Code reorganization is required for adding ethtool --set-ring feature.
> First seven patches are for code reorganization.  The last patch is for
> adding this feature.
> 
> Change Log:
> V1 -> V2
>  Only patch #8 was changed:  unnecessary parentheses were removed in two
>  if-statements in lio_ethtool_set_ringparam().

Series applied.
