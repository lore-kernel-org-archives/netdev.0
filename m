From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: realtek: 8139cp: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 06 Mar 2017 17:07:10 -0800 (PST)
Message-ID: <20170306.170710.2118512011230983117.davem@davemloft.net>
References: <1487749827-20191-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fgao@ikuai8.com, jarod@redhat.com, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754390AbdCGBHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:07:40 -0500
In-Reply-To: <1487749827-20191-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 22 Feb 2017 08:50:27 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
