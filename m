From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] vxlan, geneve: fix hlist corruption
Date: Mon, 03 Jul 2017 02:37:17 -0700 (PDT)
Message-ID: <20170703.023717.1772269541614826151.davem@davemloft.net>
References: <cover.1499014738.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, longman@redhat.com, linville@tuxdriver.com,
        pshelar@ovn.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753336AbdGCJhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:37:22 -0400
In-Reply-To: <cover.1499014738.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Sun,  2 Jul 2017 19:00:56 +0200

> Fix memory corruption introduced with the support of both IPv4 and IPv6
> sockets in a single device. The same bug is present in VXLAN and Geneve.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Series applied and queued up for -stable, thanks.
