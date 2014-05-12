From: Cong Wang <cwang@twopensource.com>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm
Date: Mon, 12 May 2014 15:01:52 -0700
Message-ID: <CAHA+R7O7yGaMJ+e=nrTmvt+wK7h0kF9okZPTzGseJZa1PiJg9Q@mail.gmail.com>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:32992 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaELWBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 18:01:53 -0400
Received: by mail-la0-f52.google.com with SMTP id gl10so2410672lab.39
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 15:01:52 -0700 (PDT)
In-Reply-To: <1399928384-24143-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 1:59 PM, Florian Westphal <fw@strlen.de> wrote:
> This patch series adds support for the Datacenter TCP (DCTCP) congestion
> control algorithm.
>
> Please see individual patches' changelog for the details. A summary
> of DCTCP and test results can be found in patch 5.
>

Is DCTCP draft accepted by IETF? It looks like there is some issue
with the design:

http://www.ietf.org/mail-archive/web/tcpm/current/msg08693.html
