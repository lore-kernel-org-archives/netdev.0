From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: /proc/net/* read drops data
Date: Fri, 05 Sep 2003 02:13:07 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030905.021307.123497946.yoshfuji@linux-ipv6.org>
References: <20030904004638.1d4b001d.davem@redhat.com>
	<Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: jfbeam@bluetronic.net
In-Reply-To: <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net> (at Thu, 4 Sep 2003 12:25:16 -0400 (EDT)), Ricky Beam <jfbeam@bluetronic.net> says:

> The list:
> (file)			(bs=1)	(bs=10000)
> /proc/net/igmp		122     191
> /proc/net/route		128     384
> /proc/net/rt_acct	0	4096
> /proc/net/rt_cache	384     512
> /proc/net/tcp		1800    1950
> /proc/net/udp		1024    1152

Okay, I'll seek the code.
--yoshfuji
