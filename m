From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 09:54:48 -0700 (PDT)
Message-ID: <20170926.095448.889779231752846224.davem@davemloft.net>
References: <20170926092231.21289-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969209AbdIZQys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 12:54:48 -0400
In-Reply-To: <20170926092231.21289-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 26 Sep 2017 11:22:31 +0200

> IS_ERR() already implies unlikely(), so it can be omitted.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
