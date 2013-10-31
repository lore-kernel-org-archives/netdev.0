From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: enable sockets to use MSG_FASTOPEN by
 default
Date: Thu, 31 Oct 2013 16:19:58 -0700
Message-ID: <1383261598.19864.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383236372-1317-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	ncardwell@google.com, sivasankar@cs.ucsd.edu
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:45549 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3JaXUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 19:20:08 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so3309105pab.0
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 16:20:08 -0700 (PDT)
In-Reply-To: <1383236372-1317-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-31 at 09:19 -0700, Yuchung Cheng wrote:
> Applications have started to use Fast Open (e.g., Chrome browser has
> such an optional flag) and the feature has gone through several
> generations of kernels since 3.7 with many real network tests. It's
> time to enable this flag by default for applications to test more
> conveniently and extensively.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
