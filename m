From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/16] [XFRM] netlink: Clear up some of the
 CONFIG_XFRM_SUB_POLICY ifdef mess
Date: Wed, 22 Aug 2007 13:57:14 -0700 (PDT)
Message-ID: <20070822.135714.15404351.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145630.772409495@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763327AbXHVU5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:57:16 -0400
In-Reply-To: <20070822145630.772409495@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:45 +0200

> Moves all of the SUB_POLICY ifdefs related to the attribute size
> calculation into a function.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
