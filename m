From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 9 Dec 2012 16:15:07 -0500
Message-ID: <CADVnQyk0Hx-LVmo+fkMzHy9cC7MQx0ACALRXVinLhto-kpv32g@mail.gmail.com>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
	<20121209.004656.468043362420071590.davem@davemloft.net>
	<CADVnQy=PJezr79ib=JFh9drEYVa35PbgyAahP+TDKKuD3HC81Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:39288 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab2LIVPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 16:15:08 -0500
Received: by mail-ie0-f179.google.com with SMTP id k14so6092163iea.38
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 13:15:07 -0800 (PST)
In-Reply-To: <CADVnQy=PJezr79ib=JFh9drEYVa35PbgyAahP+TDKKuD3HC81Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 9, 2012 at 1:01 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Dec 9, 2012 at 12:46 AM, David Miller <davem@davemloft.net> wrote:
>>
>> Thanks a lot for working on a complete fix for these problems, I'll
>> review these patches soon.
>
> Thanks, David! I appreciate it.

I noticed another related validation issue, and submitted a separate
patch for that one, based on those previous three:

   http://patchwork.ozlabs.org/patch/204786/

Please let me know if you'd like be to regenerate them all as a single
4-patch series instead.

thanks,
neal

ps: please excuse the duplicate send of that last patch... the first
"git send-email" seemed unsuccessful, so I retried, but apparently the
first attempt actually succeeded...
