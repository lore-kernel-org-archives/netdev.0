From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 21:09:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127.210953.116254624.yoshfuji@linux-ipv6.org>
References: <20031127.173320.19253188.yoshfuji@linux-ipv6.org>
	<20031127025921.3fed8dd4.davem@redhat.com>
	<1069934643.2393.0.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <1069934643.2393.0.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1069934643.2393.0.camel@teapot.felipe-alfaro.com> (at Thu, 27 Nov 2003 13:04:04 +0100), Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> says:

> On Thu, 2003-11-27 at 11:59, David S. Miller wrote:
> 
> > I agree, using sizeof() is the less error prone way of
> > doing things like this.
> > 
> > Felipe could you please rewrite your patch like this?
> 
> Done!

Thanks. Ok to me.
--yoshfuji
