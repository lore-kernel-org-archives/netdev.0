From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [patch] IPV6: Refcount leaks in udpv6_connect()
Date: Sat, 14 Jun 2003 10:26:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614.102645.87315007.yoshfuji@linux-ipv6.org>
References: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0306132149290.4922-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi, davem@redhat.com
In-Reply-To: <Pine.LNX.4.44.0306132149290.4922-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0306132149290.4922-100000@rhea.tcs.hut.fi> (at Sat, 14 Jun 2003 00:07:25 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> A dst refcount leak had unfortunately crept into my original
> CONFIG_IPV6_SUBTREES patch and your derived udpv6_connect() patch
> (changeset 1.1215.68.12).

patch looks fine to me.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
