From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] liquidio: standardization and cleanup
Date: Thu, 27 Jul 2017 17:29:47 -0700 (PDT)
Message-ID: <20170727.172947.1222445087917230592.davem@davemloft.net>
References: <20170726190945.GA1152@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdG1A3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 20:29:49 -0400
In-Reply-To: <20170726190945.GA1152@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 26 Jul 2017 12:09:45 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> This patchset corrects some non-standard macro usage.
> 
> 1. Replaced custom MIN macro with use of standard 'min_t'.
> 2. Removed cryptic and misleading macro 'CAST_ULL'.
> 
> change log:
> V1 -> V2:
>   1. Add driver cleanup of macro 'CAST_ULL'.
> V2 -> V3:
>   1. Remove extra parentheses from previous usage of macro 'CAST_ULL'.

Series applied, thank you.
