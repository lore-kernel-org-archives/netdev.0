From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: clarify promiscuous cmd with a
 comment
Date: Tue, 13 Apr 2010 03:34:02 -0700 (PDT)
Message-ID: <20100413.033402.134116147.davem@davemloft.net>
References: <20100412083527.GA27023@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pugs@cisco.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520Ab0DMKd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:33:58 -0400
In-Reply-To: <20100412083527.GA27023@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 12 Apr 2010 14:05:27 +0530

> The promiscous cmd config code gives an impression that
> setting a port to promisc mode will unset the other port.
> This is not the case and is clarified with a comment.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
