From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Tue, 06 Feb 2007 14:41:06 -0800 (PST)
Message-ID: <20070206.144106.39659974.davem@davemloft.net>
References: <20070202120528.GA10392@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965564AbXBFWlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:41:31 -0500
In-Reply-To: <20070202120528.GA10392@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Pavlic <fpavlic@de.ibm.com>
Date: Fri, 2 Feb 2007 13:05:28 +0100

> The patch set consists of following patches:
> 
> [1/7] [S390]: Rewrite of the IUCV base code, part 1
> [2/7] [S390]: Rewrite of the IUCV base code, part 2
> [3/7] [S390]: Adapt monreader driver to new IUCV API
> [4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
> [5/7] [S390]: Adapt netiucv driver to new IUCV API
> [6/7] [S390]: Adapt special message interface to new IUCV API
> [7/7] [S390]: Add AF_IUCV socket support

I have no fundamental objections to this, although I think
I'll end up needing something similar on Niagara at some
point :-)

The list ate the first patch due to it's size.  Could you
email me a copy privately so can integrate all of your work
into my net-2.6.21 tree?

Thanks.
