From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: add fastopen support
Date: Fri, 03 May 2013 18:04:49 -0700
Message-ID: <1367629489.22983.6.camel@edumazet-glaptop>
References: <1364590317.5113.63.camel@edumazet-glaptop>
	 <20130329.165659.1297013790823482161.davem@davemloft.net>
	 <CAK6E8=fdwcFf0yeueQt+Et3MkiKY2dyuaVy6982dzUQoOxohFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:62126 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933349Ab3EDBEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 21:04:55 -0400
Received: by mail-da0-f41.google.com with SMTP id y19so1033389dan.28
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 18:04:54 -0700 (PDT)
In-Reply-To: <CAK6E8=fdwcFf0yeueQt+Et3MkiKY2dyuaVy6982dzUQoOxohFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 17:08 -0700, Yuchung Cheng wrote:
> On Fri, Mar 29, 2013 at 1:56 PM, David Miller <davem@davemloft.net> wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Fri, 29 Mar 2013 13:51:57 -0700
> >
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> ss -i can output "fastopen" attribute if socket used Fast Open
> >>
> >> Signed-off-by: Eric Dumazet <edumazet@google.com>
> >
> > Reviewed-by: David S. Miller <davem@davemloft.net>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Oh well, it seems this patch got lost.

Stephen, tell me if you want me to resend it, thanks !
