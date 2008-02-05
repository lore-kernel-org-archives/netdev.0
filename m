From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan tag match
Date: Tue, 05 Feb 2008 03:20:24 -0800 (PST)
Message-ID: <20080205.032024.208605237.davem@davemloft.net>
References: <20080131.194644.03127203.davem@davemloft.net>
	<20080131210732.25f42884@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750882AbYBELT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:19:57 -0500
In-Reply-To: <20080131210732.25f42884@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 31 Jan 2008 21:07:32 -0800

> Provide a way to use tc filters on vlan tag even if tag is buried in
> skb due to hardware acceleration.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
