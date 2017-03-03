From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] sfc: couple of fixes
Date: Fri, 03 Mar 2017 10:06:54 -0800 (PST)
Message-ID: <20170303.100654.684898400184774504.davem@davemloft.net>
References: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdCCSHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:07:30 -0500
In-Reply-To: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 3 Mar 2017 15:20:44 +0000

> First patch addresses a construct that causes sparse to error out.
> With that fixed, sparse makes some warnings on ef10.c, second patch
>  fixes one of them.

Series applied, thanks.
