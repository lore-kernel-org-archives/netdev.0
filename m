From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Tue, 23 Aug 2016 13:42:12 -0700
Message-ID: <1471984932.14381.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
         <20160823.112515.318902967155957764.davem@davemloft.net>
         <1471979019.14381.37.camel@edumazet-glaptop3.roam.corp.google.com>
         <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        samanthakumar@google.com, willemb@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Laura Abbott <labbott@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 13:06 -0700, Laura Abbott wrote:

> 
> Fixes the test for me. You're welcome to take this as a Tested-by.

Thanks Laura, I will submit an official patch immediately.
