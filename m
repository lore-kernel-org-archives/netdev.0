From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Sat, 24 Jul 2004 23:25:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724232558.7c4aea69.davem@redhat.com>
References: <20040723135945.7f50b02c.davem@redhat.com>
	<1090630154.1134.6.camel@jzny.localdomain>
	<1090675993.1161.11.camel@jzny.localdomain>
	<20040724.213323.61478122.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: hadi@cyberus.ca, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040724.213323.61478122.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 24 Jul 2004 21:33:23 -0400 (EDT)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> 1. is it okay to use unsigned long?
>    I'd rather prefer __u32 or __u64.

Me too, for public APIs use strictly sized types
please.
