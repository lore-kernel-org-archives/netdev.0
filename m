From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Improve xdp_monitor samples/bpf
Date: Fri, 06 Oct 2017 10:10:14 -0700 (PDT)
Message-ID: <20171006.101014.1383543702792317062.davem@davemloft.net>
References: <150727927390.4460.3200093291677318710.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, borkmann@iogearbox.net,
        alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751946AbdJFRKP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 13:10:15 -0400
In-Reply-To: <150727927390.4460.3200093291677318710.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 06 Oct 2017 10:41:36 +0200

> Here are some improvements to the xdp_monitor tool currently located
> under samples/bpf/.  Once the tools library libbpf become more feature
> complete, xdp_monitor should be converted to use it, and be moved into
> tools/bpf/xdp/ or tools/xdp/.

Series applied.
