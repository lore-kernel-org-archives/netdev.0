From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] cls_flow: add sanity check for the packet length
Date: Wed, 04 Aug 2010 21:55:42 -0700 (PDT)
Message-ID: <20100804.215542.02264629.davem@davemloft.net>
References: <1280933292-12176-1-git-send-email-xiaosuo@gmail.com>
	<4C59915D.1020902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750881Ab0HEEzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:55:23 -0400
In-Reply-To: <4C59915D.1020902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 04 Aug 2010 18:12:13 +0200

> Am 04.08.2010 16:48, schrieb Changli Gao:
>> The packet length should be checked before the packet data is dereferenced.
>> 
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied.
