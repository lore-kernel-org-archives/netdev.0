From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qualcomm: qca: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 20 Feb 2017 22:19:32 -0500 (EST)
Message-ID: <20170220.221932.92827690022183686.davem@davemloft.net>
References: <1487627953-18469-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdBUDTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 22:19:34 -0500
In-Reply-To: <1487627953-18469-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 20 Feb 2017 22:59:13 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied, thanks Philippe.
