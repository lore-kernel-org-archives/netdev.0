From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 14:14:07 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020928.141407.110833680.yoshfuji@linux-ipv6.org>
References: <20020928.133019.38287529.yoshfuji@linux-ipv6.org>
	<200209280444.IAA02959@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: usagi@linux-ipv6.org, kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280444.IAA02959@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

In article <200209280444.IAA02959@sex.inr.ac.ru> (at Sat, 28 Sep 2002 08:44:29 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> I am not sure that it is really interesting though. Just now I cannot
> imagine what user can invent which is not covered by system-wide rules,
> bind() and IP{V6}_PKTINFO. Well, if you think more hairy scheme is interesting,
> feel free to implement this.

we need per application (per socket) interface
for privacy extension (public address vs temporary address) and 
mobile ip (home address vs care-of address).

--
yoshfuji
