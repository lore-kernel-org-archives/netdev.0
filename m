From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Mon, 4 Nov 2002 00:22:39 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0211040019450.7526-100000@blackbird.intercode.com.au>
References: <20021103.221658.52523847.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: kisza@securityaudit.hu, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>, <netfilter-devel@lists.netfilter.org>,
   <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021103.221658.52523847.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 3 Nov 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> So, the reason why the copy of route6_me_harder() 
> lives there is because net/ipv6/ip6_output.c has not been 
> exported it.
> 

Yes.  It would be much better to use common core networking code.


- James
-- 
James Morris
<jmorris@intercode.com.au>
