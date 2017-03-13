From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: net_netdev: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 15:26:14 -0700 (PDT)
Message-ID: <20170313.152614.1626587191925692450.davem@davemloft.net>
References: <1489097413-4202-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, dave.jiang@intel.com, Allen.Hubbe@emc.com,
        linux-ntb@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753540AbdCMW0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:26:16 -0400
In-Reply-To: <1489097413-4202-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu,  9 Mar 2017 23:10:13 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
