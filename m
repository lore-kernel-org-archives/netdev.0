From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: remove rtnl_kill_links
Date: Thu, 21 Oct 2010 03:15:18 -0700 (PDT)
Message-ID: <20101021.031518.102551704.davem@davemloft.net>
References: <20101015081201.55eae031@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755511Ab0JUKOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:14:55 -0400
In-Reply-To: <20101015081201.55eae031@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 Oct 2010 08:12:01 -0700

> The function rtnl_kill_links is defined but never used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
