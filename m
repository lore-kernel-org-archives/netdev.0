From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 18:17:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.181755.739870345.yoshfuji@linux-ipv6.org>
References: <20021031.124459.66300488.yoshfuji@linux-ipv6.org>
	<13640000.1036050643@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pb@bieringer.de
In-Reply-To: <13640000.1036050643@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <13640000.1036050643@localhost> (at Thu, 31 Oct 2002 08:50:43 +0100), Peter Bieringer <pb@bieringer.de> says:

> > This patch is against linux-2.5.44+bk2 snapshot.
> 
> Do you plan also to release a patch for 2.4.20+?

<http://www.linux-ipv6.org/cvsweb/~checkout~/usagi-backport/linux24-FIX_2_4_20_pre11_ADDRCONF_PRIVACY-20021026.patch>

You need to apply the following patch too.
<http://www2.linux-ipv6.org/cvsweb/~checkout~/usagi-backport/linux24-FIX_2_4_20_pre11_ADDRCONF_TIMER-20021027.patch>

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
