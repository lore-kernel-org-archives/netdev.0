From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC V3 PATCH 00/26] Kernel NET policy
Date: Mon, 19 Sep 2016 13:39:25 -0700
Message-ID: <20160919133925.0f0b31b7@xeon-e3>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
        <1473695534.18970.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kan.liang@intel.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        alexei.starovoitov@gmail.com, jesse.brandeburg@intel.com,
        andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473695534.18970.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Sep 2016 08:52:14 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-09-12 at 07:55 -0700, kan.liang@intel.com wrote:
> > From: Kan Liang <kan.liang@intel.com>
> >   
> 
> > 
> >  Documentation/networking/netpolicy.txt |  157 ++++  
> 
> 
> I find this patch series very suspect, as
> Documentation/networking/scaling.txt is untouched.
> 
> I highly recommend you present your ideas at next netdev conference.
> 
> I really doubt the mailing lists are the best place to present your
> work, given the huge amount of code/layers you want to add in linux
> kernel.

Agreed.
