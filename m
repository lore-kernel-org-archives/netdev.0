From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 2/3] net/tcp_fastopen: Add snmp counter for
 blackhole detection
Date: Thu, 20 Apr 2017 23:07:36 -0400
Message-ID: <CADVnQyngdaeBVgkWYxR-Nf2j64BhxxuhQCko5WE55tHupNMDTQ@mail.gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com> <20170420214548.23666-2-tracywwnj@gmail.com>
 <20170420214548.23666-3-tracywwnj@gmail.com> <CAK6E8=eT7J-CRwbS_mNWj7duJ00RVUKe6BmauBbu+6+X3ezEJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35056 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034879AbdDUDII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 23:08:08 -0400
Received: by mail-oi0-f45.google.com with SMTP id j201so76423055oih.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 20:08:08 -0700 (PDT)
In-Reply-To: <CAK6E8=eT7J-CRwbS_mNWj7duJ00RVUKe6BmauBbu+6+X3ezEJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 8:30 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Thu, Apr 20, 2017 at 2:45 PM, Wei Wang <weiwan@google.com> wrote:
>> From: Wei Wang <weiwan@google.com>
>>
>> This counter records the number of times the firewall blackhole issue is
>> detected and active TFO is disabled.
>>
>> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
