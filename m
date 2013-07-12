From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: account all retransmit failures
Date: Fri, 12 Jul 2013 14:38:59 -0400
Message-ID: <CADVnQymcC3h1wFb3==XckqZUb48E8ixWg3_=wZazCOcFWiqspg@mail.gmail.com>
References: <1373653984-30249-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:45023 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965131Ab3GLSjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 14:39:00 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so6582075eak.4
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 11:38:59 -0700 (PDT)
In-Reply-To: <1373653984-30249-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 2:33 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Change snmp RETRANSFAILS stat to include timeout retransmit failures
> in addition to other loss recoveries.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>
