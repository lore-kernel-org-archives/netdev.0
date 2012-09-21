From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next v1] net: use a per task frag allocator
Date: Fri, 21 Sep 2012 13:27:30 -0700
Message-ID: <CAGK4HS98RG78Auvaai3Ny6zz5c_hccO-ShD3GuT=moRRm4+RUA@mail.gmail.com>
References: <1348073761.26523.1095.camel@edumazet-glaptop>
	<20120920.174827.1245530945282009606.davem@davemloft.net>
	<1348239433.2669.522.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348239433.2669.522.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get the following compile error with the newer version of the patch

net/sched/em_meta.c: In function =91meta_int_sk_sendmsg_off=92:
net/sched/em_meta.c:464: error: =91struct sock=92 has no member named
=91sk_sndmsg_off=92
make[1]: *** [net/sched/em_meta.o] Error 1
make: *** [net/sched/em_meta.o] Error 2



Vijay
