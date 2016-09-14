From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Tue, 13 Sep 2016 22:19:15 -0600
Message-ID: <b1f76269-a810-9034-eb52-282516b15a43@cumulusnetworks.com>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com>
 <20160908.161348.297729487225819070.davem@davemloft.net>
 <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
 <20160908.175703.1354122300312111500.davem@davemloft.net>
 <CAKD1Yr2JovZ=dmNXuDCLT6gzVtC9JZ30bW6ND=10733je60bDw@mail.gmail.com>
 <CAKD1Yr3q71ap3TQDyeuKFsZ4LTt6yEBh2pAZ5=FMnCd9UmyuGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Erik Kline <ek@google.com>
To: Lorenzo Colitti <lorenzo@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34510 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbcINETS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 00:19:18 -0400
Received: by mail-pa0-f51.google.com with SMTP id wk8so1166380pab.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 21:19:18 -0700 (PDT)
In-Reply-To: <CAKD1Yr3q71ap3TQDyeuKFsZ4LTt6yEBh2pAZ5=FMnCd9UmyuGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/16 10:00 PM, Lorenzo Colitti wrote:
> On Fri, Sep 9, 2016 at 2:23 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
>> RFC patch sent out as http://patchwork.ozlabs.org/patch/667892/ . This
>> achieves a fair bit of simplification with no or negligible
>> performance impact, because there was a lot of redundancy in the
>> parameters that were passed in.
> 
> David, any thoughts on that patch? I submitted it as RFC because I
> wasn't sure what you wanted. Should I have sent it as non-RFC instead?
> 

I realize you meant DaveM, but this one has been accepted. It's your other 2 that are marked RFC by you and in patchwork.
