From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/16] [XFRM] netlink: Rename attribyte array from
 xfrma[] to attrs[]
Date: Wed, 22 Aug 2007 14:01:08 -0700 (PDT)
Message-ID: <20070822.140108.06625771.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145631.500935706@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759433AbXHVVBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:01:10 -0400
In-Reply-To: <20070822145631.500935706@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:50 +0200

> Increases readability a lot.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.

I named it like this to mean "XFRM Attributes" :-)
