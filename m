From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] x86: bpf_jit_comp: Remove inline from static function
 definitions
Date: Tue, 09 Dec 2014 14:57:19 -0500 (EST)
Message-ID: <20141209.145719.481232465007794033.davem@davemloft.net>
References: <CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
	<1417740382.22424.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417741284.2721.26.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	lambert.quentin@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417741284.2721.26.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 04 Dec 2014 17:01:24 -0800

> Let the compiler decide instead.
> 
> No change in object size x86-64 -O2 no profiling
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
