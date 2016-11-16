From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] net: thunderx: Miscellaneous fixes
Date: Wed, 16 Nov 2016 13:28:51 -0500 (EST)
Message-ID: <20161116.132851.1120462864756652814.davem@davemloft.net>
References: <1479211562-14170-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbcKPS2x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:28:53 -0500
In-Reply-To: <1479211562-14170-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sunil.kovvuri@gmail.com
Date: Tue, 15 Nov 2016 17:35:56 +0530

> This patchset includes fixes for incorrect LMAC credits,
> unreliable driver statistics, memory leak upon interface
> down e.t.c
> 
> Changes from v1:
> - As suggested replaced bit shifting with BIT() macro
>   in the patch 'Fix configuration of L3/L4 length checking'.

Series applied, thanks.
