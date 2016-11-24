From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/phy: add trace events for mdio accesses
Date: Thu, 24 Nov 2016 11:56:20 -0500 (EST)
Message-ID: <20161124.115620.771924105433296219.davem@davemloft.net>
References: <20161122100127.5940-1-uwe@kleine-koenig.org>
        <20161122154711.26622-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, rostedt@goodmis.org, mingo@redhat.com,
        netdev@vger.kernel.org
To: uwe@kleine-koenig.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35092 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbcKXQ4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:56:23 -0500
In-Reply-To: <20161122154711.26622-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <uwe@kleine-koenig.org>
Date: Tue, 22 Nov 2016 16:47:11 +0100

> Make it possible to generate trace events for mdio read and write accesses.
> 
> Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>

Applied to net-next, thanks.
