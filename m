From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: better comments for RTO initiallization
Date: Tue, 3 Sep 2013 17:31:09 -0400
Message-ID: <CADVnQy=DoyjZ4KiYhfJB1TBzJZrk4x2z2egdP+7Yu8t_+4nv3A@mail.gmail.com>
References: <1378242875-5172-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39217 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab3ICVbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 17:31:11 -0400
Received: by mail-ea0-f174.google.com with SMTP id z15so3254967ead.19
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 14:31:09 -0700 (PDT)
In-Reply-To: <1378242875-5172-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 3, 2013 at 5:14 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Commit 1b7fdd2ab585("tcp: do not use cached RTT for RTT estimation")
> removes important comments on how RTO is initialized and updated.
> Hopefully this patch puts those information back.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_metrics.c | 26 ++++++++++++++++++++------
>  1 file changed, 20 insertions(+), 6 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Yuchung!

neal
