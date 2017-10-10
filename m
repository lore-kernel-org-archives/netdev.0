From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Tue, 10 Oct 2017 10:39:18 -0700 (PDT)
Message-ID: <20171010.103918.358738948563291074.davem@davemloft.net>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
        <20171009.205228.714368596112967819.davem@davemloft.net>
        <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756424AbdJJRjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:39:19 -0400
In-Reply-To: <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 10 Oct 2017 11:29:33 -0400

> If there is a way to expose these stats through vhost_net directly,
> instead of through tun, that may be better. But I did not see a
> suitable interface. Perhaps debugfs.

Please don't use debugfs, thank you :-)
