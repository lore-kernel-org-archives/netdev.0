From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] net: ethernet: Allow Marvell &
 Freescale to COMPILE_TEST
Date: Wed, 16 Nov 2016 14:02:58 -0500 (EST)
Message-ID: <20161116.140258.1654275132379916645.davem@davemloft.net>
References: <20161116004037.20941-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47742 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbcKPTDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:03:00 -0500
In-Reply-To: <20161116004037.20941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 15 Nov 2016 16:40:32 -0800

> This patch series allows most of the Freescale Ethernet drivers to
> be built with COMPILE_TEST and all Marvell drivers to build with
> COMPILE_TEST.

Looks like the kbuild robot found some problems with this.
