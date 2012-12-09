From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 9 Dec 2012 01:01:55 -0500
Message-ID: <CADVnQy=PJezr79ib=JFh9drEYVa35PbgyAahP+TDKKuD3HC81Q@mail.gmail.com>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
	<20121209.004656.468043362420071590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:41637 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab2LIGH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 01:07:26 -0500
Received: by mail-ie0-f181.google.com with SMTP id 16so5571822iea.26
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2012 22:07:26 -0800 (PST)
In-Reply-To: <20121209.004656.468043362420071590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 9, 2012 at 12:46 AM, David Miller <davem@davemloft.net> wrote:
>
> Thanks a lot for working on a complete fix for these problems, I'll
> review these patches soon.

Thanks, David! I appreciate it.

neal
