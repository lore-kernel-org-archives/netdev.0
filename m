From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Thu, 29 Sep 2016 00:29:30 +0800
Message-ID: <CADvbK_fAgk3hvEaR4zZjuH_ch9AbLkM3pSk_B7bHGmrpnsZRvQ@mail.gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com> <20160928.081303.661512609700070565.davem@davemloft.net>
 <CADvbK_eKrZaGf0uDsCBdkWCw9e51W-HVL=_WLsR4RaSKjNmqqA@mail.gmail.com> <20160928.111716.1982951742537758888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35426 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932916AbcI1Q3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:29:31 -0400
In-Reply-To: <20160928.111716.1982951742537758888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> That doesn't matter.  This happens all the time.
>
> The way you handle this is you submit patch #1 targetting 'net' and
> wait for it to get into 'net' and propagate into 'net-next'.  When
> that happens you can submit patches #2-5 as a second patch series
> targetting 'net-next'.

Thanks, will reorganize them.
