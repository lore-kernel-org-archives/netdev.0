From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: linux-next: Tree for May 10 (net/phy)
Date: Thu, 10 May 2012 22:36:55 -0400
Message-ID: <CAP=VYLon7XRoh9s==wGYjUPNAYaTk8QQx7FGRnaDR97v+O-zXA@mail.gmail.com>
References: <20120510192635.c6f3a55196bbf65f13956e44@canb.auug.org.au> <4FAC35E2.4060900@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4FAC35E2.4060900@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2012 at 5:40 PM, Randy Dunlap <rdunlap@xenotime.net> wrote:
> On 05/10/2012 02:26 AM, Stephen Rothwell wrote:
>
>> Hi all,
>>
>> Changes since 20120508:
>
>
>
> ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!

Not just randconfig, but also powerpc allmodconfig:

http://kisskb.ellerman.id.au/kisskb/buildresult/6291463/

Adding ppc ML to cc.

P.
--


>
> Full randconfig file is attached.
>
> --
> ~Randy
