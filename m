From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ipv4-mapped ipv4 connect() for UDP broken in test10
Date: Fri, 28 Nov 2003 03:24:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.032414.10121318.yoshfuji@linux-ipv6.org>
References: <20031126081745.GA31415@codeblau.de>
	<20031126.190407.102714104.yoshfuji@linux-ipv6.org>
	<20031127165620.GA13079@codeblau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: felix-kernel@fefe.de
In-Reply-To: <20031127165620.GA13079@codeblau.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031127165620.GA13079@codeblau.de> (at Thu, 27 Nov 2003 17:56:20 +0100), Felix von Leitner <felix-kernel@fefe.de> says:

> Thus spake YOSHIFUJI Hideaki / ?$B5HF#1QL@ (yoshfuji@linux-ipv6.org):
> > Please apply this patch.
> > (But I'm not sure this fix your problem...)
> 
> Does not help.

really?

> dnscache is still sending the packets out, but I don't see them in
> tcpdump on any interface.

Hmm...

BTW, Seeing is believing; please specify the exact source / code, 
setting and the log. They will help us much better than tons of 
descriptions.

--yoshfuji
