From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in ip6_xmit
Date: Mon, 07 Dec 2015 06:39:04 -0800
Message-ID: <1449499144.25029.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+aJdFhzX-QKQR3ZNZ=MHPoNQdoS6arFaVn0c4GgUzfb0g@mail.gmail.com>
	 <1449498980.25029.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449498980.25029.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-12-07 at 06:36 -0800, Eric Dumazet wrote:


> Thanks
> 

Also note that Dave Jones reported a SCTP problem fixed by : 

https://patchwork.ozlabs.org/patch/553068/
