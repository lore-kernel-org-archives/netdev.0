From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 20:02:51 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271602.UAA21381@sex.inr.ac.ru>
References: <20020928.001742.125874265.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.ORG (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.001742.125874265.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 27, 2 07:45:03 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This patch supports standard default source address selection
> algorithm.

To all that I remember we had long discussion about this ages ago.
I said I hate this. Such complicated selection without caching is _bug_.
I see nothing improved since that time, except for the function became
even more hairy. :-)

Alexey
