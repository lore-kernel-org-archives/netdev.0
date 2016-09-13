From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 13 Sep 2016 13:32:22 -0700
Message-ID: <1473798742.14269.4.camel@gmail.com>
References: <20160913171950.GC32643@uranus>
         <1473791620.14269.2.camel@gmail.com>
         <69DF2AA5-F813-476F-BB10-B3CB35656512@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "avagin@openvz.org" <avagin@openvz.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <69DF2AA5-F813-476F-BB10-B3CB35656512@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-13 at 20:18 +0000, Rustad, Mark D wrote:
> Greg <gvrose8192@gmail.com> wrote:
> 
> > Someday Linux will be a modern OS that just includes IPV6 and forces a
> > config option to NOT have it.
> >
> > That'll be great.  All the IS_ENABLED_(CONFIG_IPV6) scattered everywhere
> > is nuts.
> >
> > </editorial comment>
> 
> Better wait until everyone at least *has* IPv6! I have yet to have IPv6  
> deployed on any of my employer's networks or get IPv6 service from any ISP  
> at my home. When I was at Apple in the 90's I was told that Apple needed  
> IPv6 by next year or "we were dead". Well Apple nearly died, but IPv6 had  
> nothing to do with that! And I still haven't experienced an IPv6  
> deployment! Yeah, I have run it a bit point-to-point to resolve technical  
> issues, but that isn't a "deployment" and not very interesting.
> 
> As much as we would like things to move faster, much of the world just  
> doesn't. Witness the e1000 discussion today for example. Hardware doesn't  
> vanish overnight, and I know that my ISP has a network full of CPE that  
> doesn't do IPv6, so I'm not expecting their status to change any time soon.

Well that's why we can have a configuration to turn it off...

But yeah.  /pipedream

- Greg

> 
> It would be great though.
> </pipedream>
> 
> --
> Mark Rustad, Networking Division, Intel Corporation
