From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH iproute2 net-next] nstat: add sctp snmp support
Date: Mon, 5 Sep 2016 11:31:23 +0800
Message-ID: <CAPwn2JReMMXSEzSN0SmW+d06dAs8ahvmTb0M6zZ0aCTxdPUhTg@mail.gmail.com>
References: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com> <20160902100912.GC5252@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:32827 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753023AbcIEDbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 23:31:25 -0400
Received: by mail-oi0-f52.google.com with SMTP id y2so12837990oie.0
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 20:31:24 -0700 (PDT)
In-Reply-To: <20160902100912.GC5252@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-02 18:09 GMT+08:00 Phil Sutter <phil@nwl.cc>:
> Did you forget to add the load call to update_db(), or am I missing
> something?

Opps, forgot to add it there. I will send patchv2 for this issue.

Thanks
Hangbin

> Apart from that, looks nice and clean.
>
> Cheers, Phil
