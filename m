From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: FIX
Date: Tue, 27 Jan 2004 07:01:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040127.070142.93371828.yoshfuji@linux-ipv6.org>
References: <20040124131307.GB2666@bender.home.hensema.net>
	<20040126.123042.104046496.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: erik@hensema.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, acme@conectiva.com.br
In-Reply-To: <20040126.123042.104046496.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040126.123042.104046496.davem@redhat.com> (at Mon, 26 Jan 2004 12:30:42 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> 
> Ok, I've figured out the bug.  Arnaldo only fixed one of the
> two incorrect calls to sk_add_node() which should both be
> __sk_add_node().

Thanks you!

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
