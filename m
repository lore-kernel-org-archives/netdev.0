From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bfin_mac: Remove unused stats member
 from struct bfin_mac_local
Date: Mon, 27 Mar 2017 16:02:10 -0700 (PDT)
Message-ID: <20170327.160210.2043728842958578564.davem@davemloft.net>
References: <20170327065511.27108-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752657AbdC0XC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:02:27 -0400
In-Reply-To: <20170327065511.27108-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 27 Mar 2017 08:55:11 +0200

> The bfin_mac driver keeps its statistics in net_device->stats, so the
> stats member in struct bfin_mac_local is unused. Remove it, as well as
> the accompanying comment.
> 
> Cc: adi-buildroot-devel@lists.sourceforge.net
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
