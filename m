From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: v2 [PATCH 2/2] ipv4: Do cleanup for ip_mr_init
Date: Thu, 03 Jul 2008 16:10:16 +0900 (JST)
Message-ID: <20080703.161016.66896752.yoshfuji@linux-ipv6.org>
References: <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
	<486C50AE.7000207@cn.fujitsu.com>
	<486C51F0.4010205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36039 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933539AbYGCHJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:09:11 -0400
In-Reply-To: <486C51F0.4010205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <486C51F0.4010205@cn.fujitsu.com> (at Thu, 03 Jul 2008 12:13:36 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> Same as ip6_mr_init(), make ip_mr_init() return errno if fails.
> But do not do error handling in inet_init(), just print a msg.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied to my linux-2.6-next tree.  Thanks.

--yoshfuji
