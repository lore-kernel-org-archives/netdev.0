From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ping6 to own link-local address
Date: Fri, 06 Apr 2007 16:35:31 +0900 (JST)
Message-ID: <20070406.163531.51929668.yoshfuji@linux-ipv6.org>
References: <20070321.002609.58216683.yoshfuji@linux-ipv6.org>
	<20070328.165748.48153731.yoshfuji@linux-ipv6.org>
	<20070328.014533.112621902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org, CHINEN@jp.ibm.com,
	yoshfuji@linux-ipv6.org, torvalds@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40593 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767542AbXDFHei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 03:34:38 -0400
In-Reply-To: <20070328.014533.112621902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070328.014533.112621902.davem@davemloft.net> (at Wed, 28 Mar 2007 01:45:33 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > > > [IPV6] ROUTE: Do not route packets to link-local address on other device.
> > > > 
> > > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a0d78ebf3a0e33a1aeacf2fc518ad9273d6a1c2f
> > > 
> > > Right.  Hmm...
> > 
> > Well, 2.6.21 is coming.  I think it is better to revert it for now.
> > Current situation is more critical than the original.
> > 
> > Dave?
> 
> I will look into this and make some kind of decision on how
> to proceed tomorrow.

Dave?

I do think this is a regression in 2.6.21-rcs, and it is much
better to revert it.

Thank you.

--yoshfuji
