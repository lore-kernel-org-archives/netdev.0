From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vlan tag match
Date: Thu, 31 Jan 2008 21:50:25 -0800
Message-ID: <20080131215025.4ad118f2@extreme>
References: <20080131.194644.03127203.davem@davemloft.net>
	<20080131210732.25f42884@extreme>
	<47A2AF6A.1060200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33518 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667AbYBAFu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 00:50:28 -0500
In-Reply-To: <47A2AF6A.1060200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 01 Feb 2008 06:34:34 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Provide a way to use tc filters on vlan tag even if tag is buried in
> > skb due to hardware acceleration.
> 
> Looks reasonable. Would you like to add the same feature to the
> flow classifier?
> 

Yes, that would be good.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
