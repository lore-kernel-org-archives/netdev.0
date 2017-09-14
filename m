From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tls: make tls_sw_free_resources static
Date: Thu, 14 Sep 2017 09:56:14 -0700 (PDT)
Message-ID: <20170914.095614.2295942497121793957.davem@davemloft.net>
References: <20170914112225.4296-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, davejwatson@fb.com,
        netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751255AbdINQ4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 12:56:17 -0400
In-Reply-To: <20170914112225.4296-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 14 Sep 2017 13:22:25 +0200

> Make the needlessly global function tls_sw_free_resources static to fix
> a gcc/sparse warning.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
