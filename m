From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH next] tcp: fastopen: fix rcv_wup initialization for TFO
 server on SYN/data
Date: Tue, 30 Aug 2016 11:59:48 -0400
Message-ID: <CADVnQykJvLxLQ+OG_GQh0E-BgGzLBPt4ch4UnpaQpU7cOrUm0w@mail.gmail.com>
References: <1472572523-10449-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35226 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754557AbcH3QAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 12:00:20 -0400
Received: by mail-oi0-f51.google.com with SMTP id j203so32158956oih.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 09:00:20 -0700 (PDT)
In-Reply-To: <1472572523-10449-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, there's a typo in the subject line: that should be "net" rather
than "next" (I'm proposing "net" since it's a bug fix).

Looks like "git am" strips this mistake, but I'm happy to resubmit if it helps.

thanks,
neal
