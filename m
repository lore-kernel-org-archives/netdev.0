From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] doc: document MSG_ZEROCOPY
Date: Fri, 01 Sep 2017 10:39:48 -0700 (PDT)
Message-ID: <20170901.103948.870635761870673720.davem@davemloft.net>
References: <20170901160141.54616-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, brouer@redhat.com,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIARjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:39:49 -0400
In-Reply-To: <20170901160141.54616-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri,  1 Sep 2017 12:01:41 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Documentation for this feature was missing from the patchset.
> Copied a lot from the netdev 2.1 paper, addressing some small
> interface changes since then.
> 
> Changes
>   v1 -> v2
>     - change email discussion URL format
>     - clarify that u32 counter is per-syscall, unsigned and
>       wraps after UINT_MAX calls
>     - describe errno on send failure specific to MSG_ZEROCOPY
>     - a few very minor rewordings
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
