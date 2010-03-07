From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix a race in ks8695_poll
Date: Sun, 07 Mar 2010 15:28:57 -0800 (PST)
Message-ID: <20100307.152857.121320180.davem@davemloft.net>
References: <1267842962.2669.2.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	yegorslists@googlemail.com
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751437Ab0CGX2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:28:38 -0500
In-Reply-To: <1267842962.2669.2.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Sat, 06 Mar 2010 10:36:02 +0800

> fix a race at the end of NAPI processing in ks8695_poll() function.
> 
> Signed-off-by:Figo.zhang <figo1802@gmail.com>

Applied.
