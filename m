From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Introduce nested and byteorder flag to netlink
 attribute
Date: Wed, 12 Sep 2007 05:45:26 -0700 (PDT)
Message-ID: <20070912.054526.28801463.davem@davemloft.net>
References: <20070912124145.GC18480@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:52893
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966337AbXILMpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:45:47 -0400
In-Reply-To: <20070912124145.GC18480@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 12 Sep 2007 14:41:45 +0200

> This change allows the generic attribute interface to be used within
> the netfilter subsystem where this flag was initially introduced.
> 
> The byte-order flag is yet unused, it's intended use is to
> allow automatic byte order convertions for all atomic types.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-2.6.24, thanks Thomas.
