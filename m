From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] xdp: adjust xdp redirect tracepoint
Date: Fri, 18 Aug 2017 16:19:09 -0700 (PDT)
Message-ID: <20170818.161909.1253983016120774487.davem@davemloft.net>
References: <150298692691.6608.11908184719252996949.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdHRXTK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:19:10 -0400
In-Reply-To: <150298692691.6608.11908184719252996949.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 17 Aug 2017 18:22:27 +0200

> Working on streamlining the tracepoints for XDP.  The eBPF programs
> and XDP have no flow-control or queueing.  Investigating using
> tracepoint to provide a feedback on XDP_REDIRECT xmit overflow events.

Series applied, thanks.
