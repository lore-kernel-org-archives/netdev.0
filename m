From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2 fwmark feature request
Date: Tue, 18 Jan 2005 13:17:57 +0100
Message-ID: <20050118121757.GN26856@postel.suug.ch>
References: <41ECC61E.7060908@cardvn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nguyen Dinh Nam <64vn@cardvn.net>
Content-Disposition: inline
In-Reply-To: <41ECC61E.7060908@cardvn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Nguyen Dinh Nam <41ECC61E.7060908@cardvn.net> 2005-01-18 15:17
> There are 2^32 values for fwmark, it's a hugh number.
> netfilter deal with it better than iproute2, particularly, there is an 
> optional mask to apply to the fwmark before comparing it with some value 
> (mark module of iptables). It's very helpful because we can use that 32 
> bits to store several sub values at the same time.
> So it'll be cool if the syntax is
> SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark 
> FWMARK[/MASK] ]

http://oss.sgi.com/archives/netdev/2005-01/msg00548.html

Wait 2-3 weeks and it will be all finished.
