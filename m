From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Check connect address in NETLINK
Date: Tue, 29 Jun 2004 15:14:33 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629111433.GA28463@ms2.inr.ac.ru>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040629084552.GA6202@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Or we can set the disconnected pid to a negative value since POSIX
> requires pid_t to be signed.  I see that you've reserved everything
> between -4096 and 0.  So perhaps we can pick -1?

I think we can.

Alexey
