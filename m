From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] [XFRM] netlink: Enhance indexing of the
 attribute array
Date: Wed, 22 Aug 2007 13:59:52 -0700 (PDT)
Message-ID: <20070822.135952.45092244.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145631.348072934@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758671AbXHVU77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:59:59 -0400
In-Reply-To: <20070822145631.348072934@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:49 +0200

> nlmsg_parse() puts attributes at array[type] so the indexing
> method can be simpilfied by removing the obscuring "- 1".
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
