From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Wed, 14 Sep 2016 13:00:09 +0900
Message-ID: <CAKD1Yr3q71ap3TQDyeuKFsZ4LTt6yEBh2pAZ5=FMnCd9UmyuGA@mail.gmail.com>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com>
 <20160908.161348.297729487225819070.davem@davemloft.net> <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
 <20160908.175703.1354122300312111500.davem@davemloft.net> <CAKD1Yr2JovZ=dmNXuDCLT6gzVtC9JZ30bW6ND=10733je60bDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Erik Kline <ek@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38905 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbcINEAb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 00:00:31 -0400
Received: by mail-it0-f48.google.com with SMTP id n143so6514600ita.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 21:00:31 -0700 (PDT)
In-Reply-To: <CAKD1Yr2JovZ=dmNXuDCLT6gzVtC9JZ30bW6ND=10733je60bDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 2:23 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> RFC patch sent out as http://patchwork.ozlabs.org/patch/667892/ . This
> achieves a fair bit of simplification with no or negligible
> performance impact, because there was a lot of redundancy in the
> parameters that were passed in.

David, any thoughts on that patch? I submitted it as RFC because I
wasn't sure what you wanted. Should I have sent it as non-RFC instead?
