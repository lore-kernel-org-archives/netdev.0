From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: CONFIG_IPV6_SUBTREES (was [patch]: CONFIG_IPV6_SUBTREES fix
 for MIPv6)
Date: Fri, 06 Jun 2003 19:32:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606.193218.117654914.yoshfuji@linux-ipv6.org>
References: <20030605.191224.68706097.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0306052009580.32033-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com, nakam@linux-ipv6.org,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0306052009580.32033-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0306052009580.32033-100000@rhea.tcs.hut.fi> (at Fri, 6 Jun 2003 11:48:36 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> Since the initial mode of communication between a mobile node (using its
> home address) and any correspondent node is reverse tunneling we at least
> need something like a default (i.e. a non-host) route through the tunnel
> for the MN's home address.

Excuse me, please forget anything related to "Mobile IP" during this
discussion; do not assume that Mobile IP is the only user of 
CONFIG_IPV6_SUBTREES.  

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
