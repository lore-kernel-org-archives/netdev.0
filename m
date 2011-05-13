From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Fri, 13 May 2011 19:27:13 +0200
Message-ID: <1305307633.3866.61.camel@edumazet-laptop>
References: <4DCD6658.3020901@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: TB <lkml@techboom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DCD6658.3020901@techboom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 mai 2011 =C3=A0 13:11 -0400, TB a =C3=A9crit :
> This is the 2.6.38.5 kernel with the patch in
> [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide error
>=20
> Had this crash a few days ago, but never got any response to subseque=
nt
> emails. Another server crashed today with a network related backtrace=
,
> but netconsole did not work.

I understand you are anxious, but sending this message to lkml will
hardly find more people to look at this problem.

You sent your messages two days ago on netdev, thats not like its one o=
r
two months.

Please send us full disassembly of tcp_fragment (from vmlinux file)
