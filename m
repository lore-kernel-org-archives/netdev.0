From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][PATCH 1/3] IPv6:Check the outgoing hop limit value
Date: Tue, 10 Jun 2008 17:11:47 +0900 (JST)
Message-ID: <20080610.171147.88878758.yoshfuji@linux-ipv6.org>
References: <484E325F.4010102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59238 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbYFJILF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 04:11:05 -0400
In-Reply-To: <484E325F.4010102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <484E325F.4010102@cn.fujitsu.com> (at Tue, 10 Jun 2008 15:50:55 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

> When specifing the outgoing hop limit as ancillary data for sendmsg(),
> the kernel doesn't check the integer hop limit value as specified in 
> [RFC-3542] section 6.3.

I'm going apply this in my queue.  Thanks.

--yoshfuji
