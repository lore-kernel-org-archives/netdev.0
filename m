From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 17:04:43 -0700 (PDT)
Message-ID: <20160908.170443.533565891486140434.davem@davemloft.net>
References: <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
        <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jojy.varghese@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbcIIAEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:04:53 -0400
In-Reply-To: <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jojy Varghese <jojy.varghese@gmail.com>
Date: Thu, 8 Sep 2016 16:33:38 -0700

> Sorry last patch was just the delta over my original patch. Here is
> the complete patch:

It looks like you are grasping at straws.

Please slow down and take the time to debug this properly.

All of the mechanisms exist to make these references go away
properly, but you are seeing a leak for some reason.

Therefore, please work with Eric to discover where the real bug is
instead of posting knee-jerk reaction patches every 15 minutes.

Thank you.
