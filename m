From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net:ethernet:aquantia: Fix for RX checksum offload.
Date: Wed, 22 Mar 2017 15:48:16 -0700 (PDT)
Message-ID: <20170322.154816.1770700048486222060.davem@davemloft.net>
References: <cc4fcad0ba1a6e7ae7c55cd15fe0b4e23650c04e.1490203234.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753639AbdCVWsS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:48:18 -0400
In-Reply-To: <cc4fcad0ba1a6e7ae7c55cd15fe0b4e23650c04e.1490203234.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Wed, 22 Mar 2017 20:21:10 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> Since AQC-100/107/08 chips supports hardware checksums for RX we should indicate
> this via NETIF_F_RXCSUM flag.

Please resubmit this with a proper signoff.

Thank you.
