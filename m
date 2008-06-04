From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL 2.6.25] IPv6 Fixes.
Date: Wed, 04 Jun 2008 11:28:26 +0900 (JST)
Message-ID: <20080604.112826.09276340.yoshfuji@linux-ipv6.org>
References: <20080604.095245.113187917.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58054 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbYFDC1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 22:27:49 -0400
In-Reply-To: <20080604.095245.113187917.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080604.095245.113187917.yoshfuji@linux-ipv6.org> (at Wed, 04 Jun 2008 09:52:45 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Dave,
> 
> Please consider pulling following fixes on top of 2.6.25.4 tree
> available at
> 	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.25.4-misc-20080604
> and push them to -stable team.

I've prepared new tree with ancillary data fixes (last 2 changes for
net-2.6 tree; applicable without adjustments).  If they are okay for -stable,
please use 
   git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.25.4-misc-20080604a
instead.

Thanks.

--yoshfuji
