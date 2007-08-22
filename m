From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/16] [XFRM] netlink: Inline attach_encap_tmpl(),
 attach_sec_ctx(), and attach_one_addr()
Date: Wed, 22 Aug 2007 14:03:50 -0700 (PDT)
Message-ID: <20070822.140350.67413559.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145632.087638328@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762169AbXHVVEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:04:06 -0400
In-Reply-To: <20070822145632.087638328@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:54 +0200

> These functions are only used once and are a lot easier to understand if
> inlined directly into the function.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied.

Thanks for doing all of this work Thomas! :)
