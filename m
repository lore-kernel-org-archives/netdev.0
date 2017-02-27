From: David Miller <davem@davemloft.net>
Subject: Re: phy deadlock -stable backport request
Date: Mon, 27 Feb 2017 11:38:20 -0500 (EST)
Message-ID: <20170227.113820.751638514088877129.davem@davemloft.net>
References: <b985983c-f649-a880-8d8f-734a64e1a673@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751414AbdB0Qrz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 11:47:55 -0500
In-Reply-To: <b985983c-f649-a880-8d8f-734a64e1a673@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 27 Feb 2017 14:56:31 +0100

> I would like to request that
> 
> commit eab127717a6af54401ba534790c793ec143cd1fc
> Author: Florian Fainelli <f.fainelli@gmail.com>
> Date:   Fri Jan 20 15:31:52 2017 -0800
> 
>     net: phy: Avoid deadlock during phy_error()
 ...
> would be backported to stable branch v4.9.
> 
> I've seen this deadlock happen on v4.9.x

Ok, queued up.
