From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: v2 [PATCH 1/2] ipv6: Do cleanup for ip6_mr_init
Date: Thu, 03 Jul 2008 16:09:07 +0900 (JST)
Message-ID: <20080703.160907.96160505.yoshfuji@linux-ipv6.org>
References: <48606D1B.3040507@cn.fujitsu.com>
	<20080702.181831.32808810.yoshfuji@linux-ipv6.org>
	<486C51EA.2040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36033 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932921AbYGCHIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:08:05 -0400
In-Reply-To: <486C51EA.2040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <486C51EA.2040401@cn.fujitsu.com> (at Thu, 03 Jul 2008 12:13:30 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> If do not do it, we will get following issues:
> 1. Leaving junks after inet6_init failing halfway.
> 2. Leaving proc and notifier junks after ipv6 modules unloading.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied to my linux-2.6-next tree.  Thanks.

--yoshfuji
