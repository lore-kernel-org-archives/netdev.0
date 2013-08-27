From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Mon, 26 Aug 2013 17:28:15 -0700
Message-ID: <CAGK4HS_9cwEFdifYpe4Lq+daH2dzgaXCYOBNA+rkAnYw=imvfg@mail.gmail.com>
References: <1377400082.8828.100.camel@edumazet-glaptop>
	<20130825.025336.1040542138436523971.davem@davemloft.net>
	<CAGK4HS9T_aXJiSDaTbPfX92Z6Cqo7+EcS-k5jh6oc65yA5bf5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:56568 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab3H0A2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 20:28:16 -0400
Received: by mail-qa0-f42.google.com with SMTP id bn16so716245qab.15
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 17:28:16 -0700 (PDT)
In-Reply-To: <CAGK4HS9T_aXJiSDaTbPfX92Z6Cqo7+EcS-k5jh6oc65yA5bf5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending this as my earlier email to netdev bounced).

 On 24 August 2013 23:53, David Miller <davem@davemloft.net> wrote:
>
>
> This depends upon your TCP patch, I knew this but you really should
> be explicit about dependencies. :-)

Eric,
If you are planning to resend this patch, you may want to take care of
some trailing space issues reported by checkpatch plus some other
warnings.

Applying: pkt_sched: fq: Fair Queue packet scheduler
/usr/src/net-next/.git/rebase-apply/patch:555: trailing whitespace.
/usr/src/net-next/.git/rebase-apply/patch:613: trailing whitespace.
/usr/src/net-next/.git/rebase-apply/patch:751: trailing whitespace.
}
/usr/src/net-next/.git/rebase-apply/patch:755: trailing whitespace.
qdisc_watchdog_cancel(&q->watchdog);
/usr/src/net-next/.git/rebase-apply/patch:821: trailing whitespace.


Thanks,
Vijay
