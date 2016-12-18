From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davicom: dm9000: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 17 Dec 2016 21:32:10 -0500 (EST)
Message-ID: <20161217.213210.1240807904266217767.davem@davemloft.net>
References: <1481706118-13076-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.jarzmik@free.fr, mugunthanvnm@ti.com, marcel@ziswiler.com,
        jarod@redhat.com, s.nawrocki@samsung.com, fw@strlen.de,
        harvey.hunt@imgtec.com, netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47524 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752867AbcLRCcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:32:12 -0500
In-Reply-To: <1481706118-13076-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 14 Dec 2016 10:01:58 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
