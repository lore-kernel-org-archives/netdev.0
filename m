From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 11:06:08 -0700
Message-ID: <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110918.022125.1554085675403900813.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/9/17 David Miller <davem@davemloft.net>:
>
> dpward (2):
> =A0 =A0 =A0net: Make flow cache namespace-aware
> =A0 =A0 =A0net: Handle different key sizes between address families i=
n flow cache
>
> nhorman (1):
> =A0 =A0 =A0net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
>
> rajan.aggarwal85@gmail.com (1):
> =A0 =A0 =A0net/can/af_can.c: Change del_timer to del_timer_sync

Guys, if somebody has such a broken email setup that they don't even
show their own name, don't take patches from them.

If you cannot even set up email sanely, there is zero reason to
believe that the patch should be good. And if the patch is trivial and
you want to take it despite the source of the patch being crap, please
spend the five seconds to fix it up.

Proper names are part of the commit message. Don't make it look like
crap. I get ugly flashbacks to SVN or CVS when I see stuff like this.
Don't do it.

                          Linus
