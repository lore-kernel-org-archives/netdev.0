From: David Miller <davem@davemloft.net>
Subject: Re: [SK_BUFF]: Fix missing offset adjustment in pskb_expand_head
Date: Mon, 09 Apr 2007 11:45:19 -0700 (PDT)
Message-ID: <20070409.114519.115938516.davem@davemloft.net>
References: <461849BB.4090805@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbXDISpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:45:20 -0400
In-Reply-To: <461849BB.4090805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 08 Apr 2007 03:47:39 +0200

> These patches fix two crashes I was getting with net-2.6.22
> on 64 bit caused by missing skb header offset adjustments
> when changing the headroom length.

Applied.
