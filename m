From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: ethernet: ti: cpsw: sync rates for channels
 in dual emac mode
Date: Sat, 10 Dec 2016 17:30:58 -0500 (EST)
Message-ID: <20161210.173058.1191365813786924768.davem@davemloft.net>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
        <1481372630-14914-6-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753338AbcLJWa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 17:30:59 -0500
In-Reply-To: <1481372630-14914-6-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 10 Dec 2016 14:23:50 +0200

> The channels are common for both ndevs in dual emac mode. Hence, keep
> in sync their rates.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
