From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 03 Nov 2002 22:20:10 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021103.222010.31188042.yoshfuji@linux-ipv6.org>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
	<1036328414.1048.3.camel@arwen>
	<20021103.221658.52523847.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kisza@securityaudit.hu
In-Reply-To: <20021103.221658.52523847.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021103.221658.52523847.yoshfuji@linux-ipv6.org> (at Sun, 03 Nov 2002 22:16:58 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> So, the reason why the copy of route6_me_harder() 
> lives there is because net/ipv6/ip6_output.c has not been 
                                               ~~~~~~~~~~~~does not
> exported it.
  ~~~~~~~~export

--yoshfuji
