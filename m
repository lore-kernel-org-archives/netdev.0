From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v2] net: ipv4: add IPPROTO_ICMP socket kind
Date: Tue, 10 May 2011 23:45:48 +0400
Message-ID: <20110510194547.GA8884@albatros>
References: <20110412.142534.183049889.davem@davemloft.net>
 <20110510180957.GA3262@albatros>
 <20110510.121550.112583080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, peak@argo.troja.mff.cuni.cz,
	kees.cook@canonical.com, dan.j.rosenberg@gmail.com,
	eugene@redhat.com, nelhage@ksplice.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110510.121550.112583080.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2011 at 12:15 -0700, David Miller wrote:
> A lot has changed in this area, your code won't even compile, so
> please adjust your patch to fit net-next-2.6 as needed, perhaps
> using net/ipv4/raw.c and net/ipv4/udp.c as a guide.

Sure, will do it.

Thanks!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
