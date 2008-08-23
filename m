From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Sat, 23 Aug 2008 11:14:46 -0300
Message-ID: <20080823111446.06a350a2@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: ilpo.jarvinen@helsinki.fi, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080822.143709.65615512.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2008 14:37:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> Yes, but it's important that you verify that the patch makes the
> problem go away when HTB is enabled.  Please make this test if you
> can.

	Correct! I tested with the HTB patches and the problem was
solved. ;) Thank you very much.


-- 
