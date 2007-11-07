From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/05] ipv6: RFC4214 Support
Date: Tue, 06 Nov 2007 21:37:50 -0800 (PST)
Message-ID: <20071106.213750.91637349.davem@davemloft.net>
References: <20071106.203845.10865897.davem@davemloft.net>
	<OF2BBF1458.DA94A99E-ON8825738C.001CC740-8825738C.001DC134@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbXKGFhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 00:37:51 -0500
In-Reply-To: <OF2BBF1458.DA94A99E-ON8825738C.001CC740-8825738C.001DC134@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 6 Nov 2007 21:26:15 -0800

> Last I heard, there are Intellectual Property claims with ISATAP,
> which is why the RFC is not standards track and which makes it
> effectively a proprietary protocol.
> 
> Unless that's been resolved, I think the claim by the IP owner is
> that it can't be distributed without a license from them. So, maybe
> not worth the effort for an experimental RFC.

If this is the case, I agree, we cannot include ISATAP
support in the kernel.
