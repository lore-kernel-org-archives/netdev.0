From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: remove two unused functions
Date: Mon, 18 Sep 2017 17:26:37 -0700 (PDT)
Message-ID: <20170918.172637.1089411363531026406.davem@davemloft.net>
References: <20170918180516.22390-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdISA0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:26:38 -0400
In-Reply-To: <20170918180516.22390-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 18 Sep 2017 11:05:16 -0700

> remove tcp_may_send_now and tcp_snd_test that are no longer used
> 
> Fixes: 840a3cbe8969 ("tcp: remove forward retransmit feature")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
