From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/16] [XFRM] netlink: Use nlmsg_broadcast() and
 nlmsg_unicast()
Date: Wed, 22 Aug 2007 13:54:50 -0700 (PDT)
Message-ID: <20070822.135450.92269087.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145630.343335774@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758667AbXHVUzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:55:01 -0400
In-Reply-To: <20070822145630.343335774@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:42 +0200

> This simplifies successful return codes from >0 to 0.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
