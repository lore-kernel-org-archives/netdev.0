From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] driver: macvlan: Replace integer number
 with bool value
Date: Mon, 14 Nov 2016 16:36:35 -0500 (EST)
Message-ID: <20161114.163635.1740752748873188751.davem@davemloft.net>
References: <1479083059-12688-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935299AbcKNVgh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:36:37 -0500
In-Reply-To: <1479083059-12688-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Mon, 14 Nov 2016 08:24:19 +0800

> From: Gao Feng <gfree.wind@gmail.com>
> 
> The return value of function macvlan_addr_busy is used as bool value,
> so use bool value instead of integer number "1" and "0".
> 
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>

Applied, thanks.
