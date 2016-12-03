From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: w83977af_ir: fix damaged whitespace
Date: Sat, 03 Dec 2016 15:09:57 -0500 (EST)
Message-ID: <20161203.150957.820803648017676027.davem@davemloft.net>
References: <20161128141951.2674778-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcLCUKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:10:25 -0500
In-Reply-To: <20161128141951.2674778-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 28 Nov 2016 15:19:43 +0100

> As David Miller pointed out for for the previous patch, the whitespace
> in some functions looks rather odd. This was caused by commit 6329da5f258a
> ("obsolete config in kernel source: USE_INTERNAL_TIMER"), which removed
> some conditions but did not reindent the code.
> 
> This fixes the indentation in the file and removes extraneous whitespace
> at the end of the lines and before tabs.
> 
> There are many other minor coding style problems in the driver, but I'm
> not touching those here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
