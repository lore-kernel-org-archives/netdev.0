From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] Minor macvlan source mode cleanups
Date: Sat, 14 Oct 2017 18:46:48 -0700 (PDT)
Message-ID: <20171014.184648.1227141930655479048.davem@davemloft.net>
References: <20171013203726.16950.32584.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJOBqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:46:49 -0400
In-Reply-To: <20171013203726.16950.32584.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 13 Oct 2017 13:40:18 -0700

> So this patch series is just a few minor cleanups for macvlan source mode.
> The first patch addresses double receives when a packet is being routed to
> the macvlan destination address, and the other addresses the pkt_type being
> updated in cases where it most likely should not be.

Series applied, thanks.
