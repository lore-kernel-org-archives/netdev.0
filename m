From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: sfc: falcon: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 02 Jan 2017 19:30:59 -0500 (EST)
Message-ID: <20170102.193059.706611277740442440.davem@davemloft.net>
References: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
        <1483293766-4581-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933326AbdACAbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 19:31:01 -0500
In-Reply-To: <1483293766-4581-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 Jan 2017 19:02:46 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - simplify the code of ef4_ethtool_get_link_ksettings
>   (feedback from Bert Kenward)

Applied.
