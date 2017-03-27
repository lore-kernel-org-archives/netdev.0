From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tehuti: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 27 Mar 2017 16:00:29 -0700 (PDT)
Message-ID: <20170327.160029.116827017054434904.davem@davemloft.net>
References: <1490558593-17411-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbdC0XAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:00:36 -0400
In-Reply-To: <1490558593-17411-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 26 Mar 2017 22:03:13 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
