From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Tue, 12 Aug 2008 14:43:09 -0300
Message-ID: <20080812144309.7d62fd86@tux>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
	<20080812.011822.155249871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: thomas.jarosch@intra2net.com, ilpo.jarvinen@helsinki.fi,
	billfink@mindspring.com, netdev@vger.kernel.org, kaber@trash.net,
	sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080812.011822.155249871.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2008 01:18:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> We had the same situation with ECN and window scaling, and my proposal
> is the same as how we handled those situations involving broken
> middleware boxes.

	Sorry for my ignorance (I'm just an user), but if the problem
is not with Linux, why this problem appeared just on 2.6.25 kernel? I
mean, with 2.6.24 and before I never had stalled connections. Just a
coincidence? Or something has changed in 2.6.25 which caused this?

	Thank you!


-- 
