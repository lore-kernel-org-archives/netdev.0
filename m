From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] net:ethernet:aquantia: Atlantic driver
 bugfixes und improvements
Date: Tue, 26 Sep 2017 13:39:33 -0700 (PDT)
Message-ID: <20170926.133933.1810326808404786359.davem@davemloft.net>
References: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com,
        pavel.belous@aquantia.com, Nadezhda.Krupnina@aquantia.com,
        simon.edelhaus@aquantia.com
To: igor.russkikh@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964856AbdIZUje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 16:39:34 -0400
In-Reply-To: <cover.1506324091.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Russkikh <igor.russkikh@aquantia.com>
Date: Mon, 25 Sep 2017 10:48:46 +0300

> This series contains bugfixes for aQuantia Atlantic driver.
> 
> Changes in v2:
> Review comments applied:
> - min_mtu set removed
> - extra mtu range check is removed
> - err codes handling improved

I'll apply this series but simply "aquantia: " is a sufficient subsystem
prefix all by itself so I have edited your Subject lines to use this
before applying.

Even if multiple subsystem tags were appropriate here, they should be
separated by spaces like "net: ethernet: ...".

Thanks.
