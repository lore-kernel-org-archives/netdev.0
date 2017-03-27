From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cris: eth_v10: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 27 Mar 2017 15:53:32 -0700 (PDT)
Message-ID: <20170327.155332.813699311022479536.davem@davemloft.net>
References: <1490467145-32724-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbdC0W4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:56:20 -0400
In-Reply-To: <1490467145-32724-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 25 Mar 2017 19:39:05 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
