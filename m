From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: tx ring can only have 2048 entries for all
 EF10 NICs
Date: Tue, 25 Apr 2017 11:19:33 -0400 (EDT)
Message-ID: <20170425.111933.283273148045687814.davem@davemloft.net>
References: <8a13989f-959d-7d93-c9a7-7e890514d99c@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.org, netdev@vger.kernel.org,
        linux-net-drivers@solarflare.com, ptalbert@redhat.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948906AbdDYPTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:19:41 -0400
In-Reply-To: <8a13989f-959d-7d93-c9a7-7e890514d99c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Tue, 25 Apr 2017 13:44:54 +0100

> Fixes: dd248f1bc65b ("sfc: Add PCI ID for Solarflare 8000 series 10/40G NIC")
> Reported-by: Patrick Talbert <ptalbert@redhat.com>
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied, thanks.
