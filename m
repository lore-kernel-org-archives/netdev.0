From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Wed, 05 Jul 2006 11:27:03 -0700 (PDT)
Message-ID: <20060705.112703.71101840.davem@davemloft.net>
References: <1151708503.11835.8.camel@trinity.ogc.int>
	<20060701.144506.74722126.davem@davemloft.net>
	<adar7119kix.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33691
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964975AbWGES0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:26:40 -0400
To: rdreier@cisco.com
In-Reply-To: <adar7119kix.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 04 Jul 2006 13:34:30 -0700

> Well, in the past it's seemed more like patches have been rejected not
> because of a blanket refusal to consider support for certain hardware,

Then why in the world would we put up explicit web pages that
say "TOE is bad, here's a list of reasons why" if we had any
intention of ever adding support for these kinds of devices?

	http://linux-net.osdl.org/index.php/TOE

It had nothing to do with a particular implementation of the patches,
it had everything to do with fundamentals of the technology.

It's going to be difficult to discuss RDMA and iWARP sanely unless you
accept the indisputable fact that we've rejected TOE as a technology
entirely, and it is an example of precedence for disallowing support
for entire classes of hardware.
