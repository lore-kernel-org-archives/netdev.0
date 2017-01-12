From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: mdio-gpio: Use modern GPIO helpers
Date: Thu, 12 Jan 2017 15:05:42 -0500 (EST)
Message-ID: <20170112.150542.674368477401449471.davem@davemloft.net>
References: <20170111205951.32363-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        linux@roeck-us.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750845AbdALUFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:05:45 -0500
In-Reply-To: <20170111205951.32363-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 11 Jan 2017 12:59:48 -0800

> This patch series modernizes the mdio-gpio and makes it switch to the
> latest and greatest API for manipulating GPIO lines, thus allowing
> some simplifications in the driver.

Series applied, thanks.
