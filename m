From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/16] [XFRM] netlink: Use nla_put()/NLA_PUT() variantes
Date: Wed, 22 Aug 2007 13:55:52 -0700 (PDT)
Message-ID: <20070822.135552.63054745.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145630.481426233@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760257AbXHVUzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:55:53 -0400
In-Reply-To: <20070822145630.481426233@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:43 +0200

> Also makes use of copy_sec_ctx() in another place and removes
> duplicated code.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
