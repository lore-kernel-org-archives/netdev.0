From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: lan78xx: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 12 Oct 2016 01:41:52 -0400 (EDT)
Message-ID: <20161012.014152.1777917821076299224.davem@davemloft.net>
References: <1476007624-9676-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: woojung.huh@microchip.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753358AbcJLFlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 01:41:55 -0400
In-Reply-To: <1476007624-9676-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  9 Oct 2016 12:07:04 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
