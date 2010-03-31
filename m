From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: eliminate useless code
Date: Tue, 30 Mar 2010 23:57:36 -0700 (PDT)
Message-ID: <20100330.235736.11075592.davem@davemloft.net>
References: <1269995097-11206-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab0CaG5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:57:37 -0400
In-Reply-To: <1269995097-11206-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 31 Mar 2010 02:24:57 +0200

> Remove duplicate declaration of symbol: struct hlist_node *node was
> already declared, the seconds declaration shadows the first one.
> 
> CC: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

I'll apply this, thanks.
