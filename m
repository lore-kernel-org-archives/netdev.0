From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Mon, 26 Aug 2013 17:45:34 -0700
Message-ID: <1377564334.8828.137.camel@edumazet-glaptop>
References: <1377400082.8828.100.camel@edumazet-glaptop>
	 <20130825.025336.1040542138436523971.davem@davemloft.net>
	 <CAGK4HS9T_aXJiSDaTbPfX92Z6Cqo7+EcS-k5jh6oc65yA5bf5A@mail.gmail.com>
	 <CAGK4HS_9cwEFdifYpe4Lq+daH2dzgaXCYOBNA+rkAnYw=imvfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61719 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341Ab3H0Apg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 20:45:36 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so4086006pdj.7
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 17:45:35 -0700 (PDT)
In-Reply-To: <CAGK4HS_9cwEFdifYpe4Lq+daH2dzgaXCYOBNA+rkAnYw=imvfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-26 at 17:28 -0700, Vijay Subramanian wrote:
> (Resending this as my earlier email to netdev bounced).
> 
>  On 24 August 2013 23:53, David Miller <davem@davemloft.net> wrote:
> >
> >
> > This depends upon your TCP patch, I knew this but you really should
> > be explicit about dependencies. :-)
> 
> Eric,
> If you are planning to resend this patch, you may want to take care of
> some trailing space issues reported by checkpatch plus some other
> warnings.

Thanks, will do ;)
