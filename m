From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
Date: Fri, 18 Jul 2003 00:28:01 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718.002801.91948420.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0307171340160.4378-100000@netcore.fi>
	<200307172052.AAA15032@dub.inr.ac.ru>
	<20030717145115.046fd5ee.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, mika.liljeberg@welho.com,
   jmorris@redhat.com, netdev@oss.sgi.com, dlstevens@us.ibm.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030717145115.046fd5ee.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030717145115.046fd5ee.davem@redhat.com> (at Thu, 17 Jul 2003 14:51:15 -0700), "David S. Miller" <davem@redhat.com> says:

> > > No user should be able to join anycast group, IMHO.
> > 
> > OK. Done, the patch enclosed.
> 
> Pekka, please ACK Alexey's patch, I'd like to apply it.

I'm not pekka, but It seems ok to me, too.

--yoshfuji
