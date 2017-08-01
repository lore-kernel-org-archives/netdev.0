From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: add related fields into
 SCM_TIMESTAMPING_OPT_STATS
Date: Mon, 31 Jul 2017 17:26:35 -0700 (PDT)
Message-ID: <20170731.172635.1588048788174020712.davem@davemloft.net>
References: <20170728172821.102562-1-tracywwnj@gmail.com>
        <20170728172821.102562-2-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, soheil@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdHAA0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:26:36 -0400
In-Reply-To: <20170728172821.102562-2-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 28 Jul 2017 10:28:21 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Add the following stats into SCM_TIMESTAMPING_OPT_STATS control msg:
>     TCP_NLA_PACING_RATE
>     TCP_NLA_DELIVERY_RATE
>     TCP_NLA_SND_CWND
>     TCP_NLA_REORDERING
>     TCP_NLA_MIN_RTT
>     TCP_NLA_RECUR_RETRANS
>     TCP_NLA_DELIVERY_RATE_APP_LMT
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
