From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: phy: broadcom: add support for
 BCM54210E
Date: Fri, 27 Jan 2017 11:29:36 -0500 (EST)
Message-ID: <20170127.112936.1094276411809218039.davem@davemloft.net>
References: <20170127104705.25162-1-zajec5@gmail.com>
        <20170127130701.4191-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, jaedon.shin@gmail.com,
        netdev@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755123AbdA0Q3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:29:38 -0500
In-Reply-To: <20170127130701.4191-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Fri, 27 Jan 2017 14:07:01 +0100

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> It's Broadcom PHY simply described as single-port
> RGMII 10/100/1000BASE-T PHY. It requires disabling delay skew and GTXCLK
> bits.
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>
> ---
> V2: Include include/linux/brcmphy.h change I forgot to commit

Applied, thanks.
