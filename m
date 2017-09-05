From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tun: rename generic_xdp to skb_xdp
Date: Tue, 05 Sep 2017 14:26:56 -0700 (PDT)
Message-ID: <20170905.142656.2300364822604448851.davem@davemloft.net>
References: <1504496169-31190-1-git-send-email-jasowang@redhat.com>
        <1504496169-31190-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com, daniel@iogearbox.net
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753139AbdIEV05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:26:57 -0400
In-Reply-To: <1504496169-31190-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  4 Sep 2017 11:36:09 +0800

> Rename "generic_xdp" to "skb_xdp" to avoid confusing it with the
> generic XDP which will be done at netif_receive_skb().
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
