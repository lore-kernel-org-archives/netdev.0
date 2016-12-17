From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] irda: irnet: add member name to the miscdevice
 declaration
Date: Sat, 17 Dec 2016 11:18:30 -0500 (EST)
Message-ID: <20161217.111830.2082158623210373435.davem@davemloft.net>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
        <20161215104250.16813-5-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758730AbcLQQSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:18:32 -0500
In-Reply-To: <20161215104250.16813-5-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 15 Dec 2016 11:42:50 +0100

> Since the struct miscdevice have many members, it is dangerous to init
> it without members name relying only on member order.
> 
> This patch add member name to the init declaration.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
