From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: caif: Remove unused stats member from
 struct chnl_net
Date: Thu, 19 Jan 2017 11:51:37 -0500 (EST)
Message-ID: <20170119.115137.278980288946479350.davem@davemloft.net>
References: <20170119150425.12559-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753802AbdASQvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:51:39 -0500
In-Reply-To: <20170119150425.12559-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 19 Jan 2017 16:04:25 +0100

> The stats member of struct chnl_net is used nowhere in the code, so it
> might as well be removed.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
