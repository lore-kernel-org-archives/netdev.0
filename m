From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 21 Feb 2007 17:09:23 +0900 (JST)
Message-ID: <20070221.170923.33306384.yoshfuji@linux-ipv6.org>
References: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
	<E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
	<20070221.000613.55507332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hasso@estpak.ee,
	netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:56894 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161123AbXBUIJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:09:13 -0500
In-Reply-To: <20070221.000613.55507332.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070221.000613.55507332.davem@davemloft.net> (at Wed, 21 Feb 2007 00:06:13 -0800 (PST)), David Miller <davem@davemloft.net> says:

> Since this technically fixes a major usability bug, I'm
> happy to apply this with the ipv6 side for 2.6.21
> 
> It is up to Yoshifuji how to handle this.  He can either add
> this patch to his ipv6 bug fix submission for 2.6.21, or he
> can just submit the ipv6 parts and I can merge Herbert's ipv4
> patch myself.
> 
> Just let me know what to do.

I'll apply Herbert change into my tree first, and I'll try pushing
both changes at the same time.

Thanks.

--yoshfuji
