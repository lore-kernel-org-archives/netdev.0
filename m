From: Jesse <j@lumiere.net>
Subject: Re: Fw: [Bug 3419] New: kernel BUG at net/ipv4/fib_semantics.c:1039!
Date: Wed, 22 Sep 2004 13:05:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922130502.N41787@leaf.lumiere.net>
References: <20040922092319.4ba5b8fb@dell_ss3.pdx.osdl.net>
 <20040922092520.U41787@leaf.lumiere.net> <20040922110120.022c170e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@osdl.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040922110120.022c170e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > I haven't had a chance to try a new snapshot version yet. I will try one
> > later today and report back.
>
> That crash should definitely be cured in the current code.
> Let us know if it is still there.

I tested 2.6.9-rc2-bk8 and the system came up cleanly, including
networking. Looks good so far.

Thanks.

---
Jesse <j@lumiere.net>
