From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Mon, 24 Feb 2003 15:58:52 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030224.155852.611429637.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0210311021560.19356-100000@netcore.fi>
	<20021101.174832.44646503.yoshfuji@linux-ipv6.org>
	<20030223.223114.65976206.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   pekkas@netcore.fi, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030223.223114.65976206.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030223.223114.65976206.davem@redhat.com> (at Sun, 23 Feb 2003 22:31:14 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> Hmmm, some thinking is needed in order to backport this to
> 2.4.x due to lack of crypto library.  I guess USAGI 2.4.x
> version of this patch uses crypto library from USAGI 2.4.x ipsec?

MD5 code in linux-2.4.x patch what I sent you was taken from 
Colin Plumb's public domain implementation.  
(USAGI itself uses KAME implementation.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
