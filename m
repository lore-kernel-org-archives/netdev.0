From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ena: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 09:54:34 -0700 (PDT)
Message-ID: <20170926.095434.1647354653998922812.davem@davemloft.net>
References: <20170926090423.16937-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netanel@annapurnalabs.com,
        saeed@annapurnalabs.com, zorik@annapurnalabs.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966179AbdIZQyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 12:54:39 -0400
In-Reply-To: <20170926090423.16937-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 26 Sep 2017 11:04:23 +0200

> IS_ERR() already implies unlikely(), so it can be omitted.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
