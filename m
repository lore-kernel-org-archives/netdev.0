From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: BUG in __skb_gso_segment
Date: Tue, 14 Feb 2017 05:54:17 -0800
Message-ID: <1487080457.8227.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+x0LGHoBF-iL5Az-nrXTBkMUfeqi0Pb-7Fne7L8ZYA6Sg@mail.gmail.com>
         <CANn89i+rqdKnRN9XH4ARqGouJaM0P2WtH9XrGQF+MJ_+mgrsaQ@mail.gmail.com>
         <CAAeHK+wfDdc_FybfsZUS0F4n9qkdCd-6V_VEEA0EgJ_vZjzRmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wfDdc_FybfsZUS0F4n9qkdCd-6V_VEEA0EgJ_vZjzRmg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-14 at 13:59 +0100, Andrey Konovalov wrote:
> On Mon, Feb 13, 2017 at 10:56 PM, Eric Dumazet <edumazet@google.com> wrote:

> Hi Eric,
> 
> >
> > 926af6273fc683cd98cd0ce7bf0d04a02eed6 is quite old ;)
> 
> Updated to 4.10-rc8 :)
> 
> >
> > Probably already fixed ?
> 
> Yes, it is.
> 
> Thanks!

Perfect, thanks for confirming this.
