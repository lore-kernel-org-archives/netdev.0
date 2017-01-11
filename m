From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add the AF_QIPCRTR entries to family name tables
Date: Tue, 10 Jan 2017 20:52:47 -0500 (EST)
Message-ID: <20170110.205247.1954415559323609519.davem@davemloft.net>
References: <20170110034856.49721-1-s-anna@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        courtney.cavin@sonymobile.com, bjorn.andersson@linaro.org
To: s-anna@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755253AbdAKBwt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:52:49 -0500
In-Reply-To: <20170110034856.49721-1-s-anna@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suman Anna <s-anna@ti.com>
Date: Mon, 9 Jan 2017 21:48:56 -0600

> Commit bdabad3e363d ("net: Add Qualcomm IPC router") introduced a
> new address family. Update the family name tables accordingly so
> that the lockdep initialization can use the proper names for this
> family.
> 
> Cc: Courtney Cavin <courtney.cavin@sonymobile.com>
> Cc: Bjorn Andersson <bjorn.andersson@linaro.org>
> Signed-off-by: Suman Anna <s-anna@ti.com>

Applied and queued up for -stable, thanks.
