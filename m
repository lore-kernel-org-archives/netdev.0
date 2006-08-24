From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Thu, 24 Aug 2006 15:04:42 +0900 (JST)
Message-ID: <20060824.150442.44820672.yoshfuji@linux-ipv6.org>
References: <11563453681815-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453682841-git-send-email-yoshfuji@linux-ipv6.org>
	<20060823.225706.03601250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53256 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030329AbWHXGCy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 02:02:54 -0400
To: davem@davemloft.net
In-Reply-To: <20060823.225706.03601250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060823.225706.03601250.davem@davemloft.net> (at Wed, 23 Aug 2006 22:57:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> Are there any other Mobile-IPV6 patches necessary for the
> kernel?

The patches cover most of MIPv6 and CN should work.
However, for HA/MN, there are small number of patches
to send.

We will send them, of course.
Nakamura-san, please describe the details.

--yoshfuji
