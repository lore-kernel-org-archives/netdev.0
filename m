From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] net: fec: remove unused interrupt
 FEC_ENET_TS_TIMER
Date: Wed, 20 Sep 2017 15:47:47 -0700 (PDT)
Message-ID: <20170920.154747.196677076987320325.davem@davemloft.net>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
        <1505867589-11784-2-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org, fabio.estevam@nxp.com,
        lznuaa@gmail.com
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbdITWrs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:47:48 -0400
In-Reply-To: <1505867589-11784-2-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Tue, 19 Sep 2017 17:33:08 -0700

> FEC_ENET_TS_TIMER is not checked in the interrupt routine
> so there is no need to enable it.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Acked-by: Fugang Duan <fugang.duan@nxp.com>

Applied.
