From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Sun, 29 Sep 2002 06:09:52 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209290209.GAA12099@sex.inr.ac.ru>
References: <20020928.172306.102654240.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020928.172306.102654240.davem@redhat.com> from "David S. Miller" at Sep 28, 2 05:23:06 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This reminds me, nothing is aparently going to make use
> of net/ipv6/ip6_fw.c, it sits unused and untouched for
> years, 

... and unwritten. :-)

> can we just detroy it? :-)

Must, I think.

Though with your current mood about per-flow cache the file
could deserve... mmm... post-mortem examination. :-)

Alexey
