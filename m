From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Aug 12 (benet/be2net)
Date: Fri, 12 Aug 2011 13:56:18 -0700
Message-ID: <20110812135618.a209d9af.rdunlap@xenotime.net>
References: <20110812171311.4d7bb640f38838bf7c34df50@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812171311.4d7bb640f38838bf7c34df50@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Aug 2011 17:13:11 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> [The kernel.org mirroring is being very slow today]

  [s.l.o.w.]
 
> The net tree gained a build failure do I used the version from
> next-20110811.


On i386:

drivers/built-in.o: In function `be_rx_eqd_update':
be_main.c:(.text+0x569229): undefined reference to `__udivdi3'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
