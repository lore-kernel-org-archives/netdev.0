From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 badness continues
Date: Tue, 04 Jan 2005 18:26:27 -0500
Message-ID: <41DB2623.7000601@pobox.com>
References: <41DA3A60.8050102@pobox.com> <20050104093335.GB7823@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050104093335.GB7823@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Tue, Jan 04, 2005 at 01:40:32AM -0500, Jeff Garzik wrote:
> 
> 
>>Standard FC2 OS with IPv6 6to4 setup as described on 
>>http://linux.yyz.us/ipv6-fc2-howto.html
> 
> 
> I upgraded my problematic machine to FC3, which somehow broke 6to4, and I
> didn't bother to reenable it again because the local DNS server (dnscache)
> just drops AAAA queries on the floor anyway, leading to lots of timeouts
> when trying to resolve host names, etc.  Ever since 6to4 was turned off
> on that box I stopped seeing these messages.

hmmm, that's annoying.  My router is still FC2, but I'll check that out 
when I upgrade it to FC3.

	Jeff
