From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-v3 0/6] net: dsa: Make bcm_sf2 utilize
 b53_common
Date: Fri, 26 Aug 2016 13:16:10 -0700 (PDT)
Message-ID: <20160826.131610.1187541386568091948.davem@davemloft.net>
References: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jonas.gorski@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60341 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbcHZUX6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 16:23:58 -0400
In-Reply-To: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 26 Aug 2016 12:18:28 -0700

> Changes in v3:
> 
> - rebase against 145dd5f9c88f6ee645662df0be003e8f04bdae93 ("net: flush the
>   softnet backlog in process context")

This is a lot better, series applied, thanks!
