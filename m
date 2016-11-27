From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Sun, 27 Nov 2016 15:27:18 -0500 (EST)
Message-ID: <20161127.152718.2014239474427472145.davem@davemloft.net>
References: <1479979021-13715-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com, mugunthanvnm@ti.com,
        roszenrami@gmail.com, f.fainelli@gmail.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753450AbcK0U1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:27:20 -0500
In-Reply-To: <1479979021-13715-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yegorslists@googlemail.com
Date: Thu, 24 Nov 2016 10:17:01 +0100

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Add the ability to query and set Energy Efficient Ethernet parameters
> via ethtool for applicable devices.
> 
> This patch doesn't activate full EEE support in cpsw driver, but it
> enables reading and writing EEE advertising settings. This way one
> can disable advertising EEE for certain speeds.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> Acked-by: Rami Rosen <roszenrami@gmail.com>
> ---
> Changes:
> 	v3: explain what features will be available with this patch (Florian Fainelli)
> 	v2: make routines static (Rami Rosen)

Does not apply cleanly to net-next, please respin.
