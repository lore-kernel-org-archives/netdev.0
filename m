From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 00/05] ipv6: RFC4214 Support
Date: Wed, 07 Nov 2007 14:55:50 +0900 (JST)
Message-ID: <20071107.145550.50882731.yoshfuji@linux-ipv6.org>
References: <20071106.203845.10865897.davem@davemloft.net>
	<OF2BBF1458.DA94A99E-ON8825738C.001CC740-8825738C.001DC134@us.ibm.com>
	<20071106.213750.91637349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net, Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38453 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbXKGFzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 00:55:47 -0500
In-Reply-To: <20071106.213750.91637349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071106.213750.91637349.davem@davemloft.net> (at Tue, 06 Nov 2007 21:37:50 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: David Stevens <dlstevens@us.ibm.com>
> Date: Tue, 6 Nov 2007 21:26:15 -0800
> 
> > Last I heard, there are Intellectual Property claims with ISATAP,
> > which is why the RFC is not standards track and which makes it
> > effectively a proprietary protocol.
> > 
> > Unless that's been resolved, I think the claim by the IP owner is
> > that it can't be distributed without a license from them. So, maybe
> > not worth the effort for an experimental RFC.
> 
> If this is the case, I agree, we cannot include ISATAP
> support in the kernel.

I guess license is no longer required for implementers of ISATAP.
Is it right, Fred?

https://datatracker.ietf.org/ipr/550/

--yoshfuji


