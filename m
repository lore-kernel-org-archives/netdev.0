From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net:ethernet:aquantia: Fix for RX checksum
 offload.
Date: Wed, 22 Mar 2017 19:41:13 -0700 (PDT)
Message-ID: <20170322.194113.1618670734085210150.davem@davemloft.net>
References: <29c8e2af99d9528db8cd4fa33c18080aaad6bef1.1490224721.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbdCWClO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:41:14 -0400
In-Reply-To: <29c8e2af99d9528db8cd4fa33c18080aaad6bef1.1490224721.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Thu, 23 Mar 2017 02:20:39 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> Since AQC-100/107/108 chips supports hardware checksums for RX we should indicate this
> via NETIF_F_RXCSUM flag.
> 
> v1->v2: 'Signed-off-by' tag added.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Applied, thanks.
