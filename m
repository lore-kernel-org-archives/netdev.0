From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Wed, 7 Sep 2016 18:48:30 +0900
Message-ID: <CAKD1Yr358X7mH1QvhFNwtj-mtv=MGa-FyUXbfXWaJXqotEyx8g@mail.gmail.com>
References: <1473240756-101966-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erik Kline <ek@google.com>, Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35040 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756971AbcIGJsw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 05:48:52 -0400
Received: by mail-it0-f47.google.com with SMTP id e124so187413177ith.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 02:48:52 -0700 (PDT)
In-Reply-To: <1473240756-101966-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 6:32 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> This adds the capability for a process that has CAP_NET_ADMIN on
> a socket to dump its mark.

Sorry for sending v2 out so soon; there are no code changes from v1,
but I corrected the commit description. I've marked v1 as superseded
and archived it in patchwork.
