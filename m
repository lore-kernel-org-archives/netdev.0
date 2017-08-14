From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: update debug console logging
 mechanism
Date: Mon, 14 Aug 2017 10:57:17 -0700 (PDT)
Message-ID: <20170814.105717.592035337202098472.davem@davemloft.net>
References: <20170812014314.GA1012@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbdHNR5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 13:57:19 -0400
In-Reply-To: <20170812014314.GA1012@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 11 Aug 2017 18:43:14 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> - remove logging dependency upon global func octeon_console_debug_enabled()
> - abstract debug console logging using console structure (via function ptr)
>   to allow for more flexible logging
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
