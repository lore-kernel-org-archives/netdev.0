From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 13:30:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020928.133019.38287529.yoshfuji@linux-ipv6.org>
References: <20020927.203606.32735488.davem@redhat.com>
	<200209280419.IAA02894@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280419.IAA02894@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200209280419.IAA02894@sex.inr.ac.ru> (at Sat, 28 Sep 2002 08:19:29 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> This is just extending ipv6 routing entry with a field to hold
> source address and, generally, making the same work as IPv4 does,
> with all the advantages, particularily capability to select preferred
> source address via routes set up by admin (RTA_PREFSRC attribute,
> "src" in "ip route add").

we need per socket preference.
can we do that with this?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
