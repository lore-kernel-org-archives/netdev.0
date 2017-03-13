From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via: via-rhine: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 19:28:41 -0700 (PDT)
Message-ID: <20170312.192841.1718036403586676821.davem@davemloft.net>
References: <1488926776-11073-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        stephen@networkplumber.org, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933477AbdCMCaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 22:30:15 -0400
In-Reply-To: <1488926776-11073-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue,  7 Mar 2017 23:46:16 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
