From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 14:54:12 -0800 (PST)
Message-ID: <20100311.145412.118613343.davem@davemloft.net>
References: <20100311140406.37ee0b83@nehalam>
	<alpine.LSU.2.01.1003112305060.11569@obet.zrqbmnf.qr>
	<20100311145059.1a020e1c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47687
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753278Ab0CKWxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:53:52 -0500
In-Reply-To: <20100311145059.1a020e1c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 11 Mar 2010 14:50:59 -0800

> But if you send 32bit truncated values when 64 bit is expected
> then users are going to complain

They already complain, a lot.

This isn't going to change the situation at all, and
I agree with Jan that consistency is the trumping factor
here.
