From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: better comments for RTO initiallization
Date: Tue, 03 Sep 2013 14:33:29 -0700
Message-ID: <1378244009.7360.43.camel@edumazet-glaptop>
References: <1378242875-5172-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:60745 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755741Ab3ICVdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 17:33:31 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so6956947pab.36
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 14:33:31 -0700 (PDT)
In-Reply-To: <1378242875-5172-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 14:14 -0700, Yuchung Cheng wrote:
> Commit 1b7fdd2ab585("tcp: do not use cached RTT for RTT estimation")
> removes important comments on how RTO is initialized and updated.
> Hopefully this patch puts those information back.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
