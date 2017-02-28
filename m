From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in rt6_nexthop_info
Date: Tue, 28 Feb 2017 05:49:14 -0800
Message-ID: <1488289754.9415.255.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+b44zwroCAg8QhNZQ5PX-ObhoKQW6VCFC9rt46JijYPYQ@mail.gmail.com>
         <1488287417.9415.237.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+ZTtDiG2q8ZS-fcR4-V1V06O-Si0EOWSaMBostShOR4jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, ycheng@google.com,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZTtDiG2q8ZS-fcR4-V1V06O-Si0EOWSaMBostShOR4jQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-28 at 14:30 +0100, Dmitry Vyukov wrote:

> I always run get_maintainer.pl on the top file. David is not listed
> for net/ipv6/route.c.
> I've added Yuchung as you said you want to partition load.

Yuchung is working on TCP stack exclusively, as far as linux kernel is
concerned.

He never submitted a single patch targeting IPv6, if this was not for a
TCP change.

netdev@vger.kernel.org is the appropriate point of contact for bugs in
linux network stacks.

Thanks.
