From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bgmac: fix reversed check for MII
 registration error
Date: Thu, 18 Aug 2016 23:25:07 -0700 (PDT)
Message-ID: <20160818.232507.284768142382203753.davem@davemloft.net>
References: <1471441051-2130-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, rafal@milecki.pl, arnd@arndb.de,
        f.fainelli@gmail.com, jon.mason@broadcom.com,
        linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754250AbcHSGZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:25:51 -0400
In-Reply-To: <1471441051-2130-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Wed, 17 Aug 2016 15:37:14 +0200

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> It was failing on successful registration returning meaningless errors.
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>
> Fixes: 55954f3bfdac ("net: ethernet: bgmac: move BCMA MDIO Phy code into a separate file")

Applied.
