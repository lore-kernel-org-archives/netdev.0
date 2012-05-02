From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Wed, 02 May 2012 20:49:57 +0200
Message-ID: <1335984597.22133.611.camel@edumazet-glaptop>
References: <1335984391-31340-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	ncardwell@google.com, nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36507 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871Ab2EBSuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 14:50:01 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so737868bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 11:50:01 -0700 (PDT)
In-Reply-To: <1335984391-31340-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 11:46 -0700, Yuchung Cheng wrote:
> This a prepartion patch that refactors the code to enter recovery
> into a new function tcp_enter_recovery(). It's needed to implement
> the delayed fast retransmit in ER.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog since v1:
>  - swaped with part 1 and part2
> ChangeLog since v2:
>  - removed RFC in commit message
>  

Acked-by: Eric Dumazet <edumazet@google.com>
