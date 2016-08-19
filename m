From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bgmac: make it clear when setting
 interface type to RMII
Date: Thu, 18 Aug 2016 23:36:29 -0700 (PDT)
Message-ID: <20160818.233629.2247737263787094338.davem@davemloft.net>
References: <1471468315-20574-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, rafal@milecki.pl, f.fainelli@gmail.com,
        jon.mason@broadcom.com, arnd@arndb.de, tremyfr@gmail.com,
        linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752936AbcHSGhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:37:17 -0400
In-Reply-To: <1471468315-20574-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Wed, 17 Aug 2016 23:11:52 +0200

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> It doesn't really change anything as BGMAC_CHIPCTL_1_IF_TYPE_RMII is
> equal to 0. It make code a bit clener, so far when reading it one could
> think we forgot to set a proper mode. It also keeps this mode code in
> sync with other ones.
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>

Applied.
