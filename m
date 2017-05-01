From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] samples/bpf: two bug fixes to
 XDP_FLAGS_SKB_MODE attaching
Date: Mon, 01 May 2017 10:42:54 -0400 (EDT)
Message-ID: <20170501.104254.1309394134995732895.davem@davemloft.net>
References: <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
        <149363073213.17600.4480290736818479957.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756873AbdEAOm4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:42:56 -0400
In-Reply-To: <149363073213.17600.4480290736818479957.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 01 May 2017 11:26:10 +0200

> Two small bugfixes for:
>  commit 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")

Series applied.
