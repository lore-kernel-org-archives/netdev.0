From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 09:09:12 +0900 (JST)
Message-ID: <20080110.090912.91321347.yoshfuji@linux-ipv6.org>
References: <20080109.153212.144388472.davem@davemloft.net>
	<20080110.084655.66182071.yoshfuji@linux-ipv6.org>
	<20080109.155544.136768603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34746 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbYAJAJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 19:09:09 -0500
In-Reply-To: <20080109.155544.136768603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080109.155544.136768603.davem@davemloft.net> (at Wed, 09 Jan 2008 15:55:44 -0800 (PST)), David Miller <davem@davemloft.net> says:

> Because of the above, the existing behavior must still stay the
> default.  I hope this is your plan.
> 
> By default Linux will not implement this SHOULD, it's a security
> issue.

Yes so far, though we may have more things to consider.

--yoshfuji
