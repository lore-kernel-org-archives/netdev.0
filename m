From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macsec: set network devtype
Date: Thu, 08 Sep 2016 17:24:07 -0700 (PDT)
Message-ID: <20160908.172407.273322865763730537.davem@davemloft.net>
References: <20160907140732.396bc2cf@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcIIAYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:24:08 -0400
In-Reply-To: <20160907140732.396bc2cf@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 7 Sep 2016 14:07:32 -0700

> The netdevice type structure for macsec was being defined but never used.
> To set the network device type the macro SET_NETDEV_DEVTYPE must be called.
> Compile tested only, I don't use macsec.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Sabrina, please review.

Thanks.
