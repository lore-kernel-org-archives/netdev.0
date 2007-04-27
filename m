From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 19:29:46 -0700 (PDT)
Message-ID: <20070426.192946.54188656.davem@davemloft.net>
References: <46311F76.9040803@redhat.com>
	<20070426.150434.91313967.davem@davemloft.net>
	<46313180.6040809@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753905AbXD0C3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 22:29:38 -0400
In-Reply-To: <46313180.6040809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 26 Apr 2007 19:10:56 -0400

> Another question: is it a good idea to even be shipping release
> kernels with Mobile IPV6 enabled? Unfortunately, "experimental"
> isn't enough to go by...

There are no known issues in the mobile-ipv6 code to
my knowledge.  At least no OOPS'ers or anything like
that.
