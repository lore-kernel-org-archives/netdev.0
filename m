From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: socket option to set TCP fast open key
Date: Fri, 20 Oct 2017 13:29:45 +0100 (WEST)
Message-ID: <20171020.132945.1085717648120622175.davem@davemloft.net>
References: <20171018182251.5486-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cpaasch@apple.com, edumazet@google.com,
        ncardwell@google.com, maheshb@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdJTM3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:29:51 -0400
In-Reply-To: <20171018182251.5486-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 18 Oct 2017 11:22:51 -0700

> New socket option TCP_FASTOPEN_KEY to allow different keys per
> listener.  The listener by default uses the global key until the
> socket option is set.  The key is a 16 bytes long binary data. This
> option has no effect on regular non-listener TCP sockets.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied.
