From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for
 linklocal is completed.
Date: Fri, 20 Jun 2008 11:32:21 +0900 (JST)
Message-ID: <20080620.113221.35150861.yoshfuji@linux-ipv6.org>
References: <4832C3CC.5070609@miraclelinux.com>
	<20080522.015807.02348209.yoshfuji@linux-ipv6.org>
	<485B1337.2000202@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: tabe@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59912 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbYFTCb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:31:28 -0400
In-Reply-To: <485B1337.2000202@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <485B1337.2000202@miraclelinux.com> (at Fri, 20 Jun 2008 11:17:27 +0900), Toyo Abe <tabe@miraclelinux.com> says:

> Hi,
> 
> I'm wondering why the fix inlined below is not included.
> I'd tested this fix w/ TAHI test suite. Then, the failed test cases - v6LC.3.1.2 Part B, Part D,
> v6LC.3.1.3 Part I, and Part J in IPv6 Stateless Address Autoconfiguration test - were all passed.
> If just waiting for verification info, I'm really sorry for the lazy response.
> 
> I think this can be merged.

Because it still an ad-hoc patch and I've been seeking better approach.
I'll send it later.

Thank you for you patience.

--yoshfuji
