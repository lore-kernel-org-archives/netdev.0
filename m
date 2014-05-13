From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm
Date: Mon, 12 May 2014 21:45:15 -0700
Message-ID: <20140512214515.7eb085af@nehalam.linuxnetplumber.net>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
	<CAHA+R7O7yGaMJ+e=nrTmvt+wK7h0kF9okZPTzGseJZa1PiJg9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44826 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaEMEpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:45:18 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so9770634pab.28
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 21:45:17 -0700 (PDT)
In-Reply-To: <CAHA+R7O7yGaMJ+e=nrTmvt+wK7h0kF9okZPTzGseJZa1PiJg9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2014 15:01:52 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Mon, May 12, 2014 at 1:59 PM, Florian Westphal <fw@strlen.de> wrote:
> > This patch series adds support for the Datacenter TCP (DCTCP) congestion
> > control algorithm.
> >
> > Please see individual patches' changelog for the details. A summary
> > of DCTCP and test results can be found in patch 5.
> >
> 
> Is DCTCP draft accepted by IETF? It looks like there is some issue
> with the design:
> 
> http://www.ietf.org/mail-archive/web/tcpm/current/msg08693.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Far more worrying is the Microsoft IPR statement relative to the RFC.
 https://datatracker.ietf.org/ipr/2319/
