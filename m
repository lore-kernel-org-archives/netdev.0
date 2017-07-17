From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Mon, 17 Jul 2017 16:57:33 -0700 (PDT)
Message-ID: <20170717.165733.1562757179072401126.davem@davemloft.net>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751351AbdGQX5h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 19:57:37 -0400
In-Reply-To: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon, 17 Jul 2017 18:09:09 -0300

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> The gpiod API checks for NULL descriptors, so there is no need to
> duplicate the check in the driver.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thanks.
