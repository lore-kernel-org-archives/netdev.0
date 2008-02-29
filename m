From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] Add Support for Sun ATCA Blade Server.
Date: Thu, 28 Feb 2008 21:26:40 -0800 (PST)
Message-ID: <20080228.212640.236979160.davem@davemloft.net>
References: <200802211734.m1LHYPFa040177@sr1-umpk-51.sfbay.sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matheos.worku@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750929AbYB2F0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 00:26:40 -0500
In-Reply-To: <200802211734.m1LHYPFa040177@sr1-umpk-51.sfbay.sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>
Date: Wed, 20 Feb 2008 08:28:43 -0800

> Ports 0 and 1 of the NIU device are connected to extended fabric through
> SERDES. Ports 2 and 3 are connected using RGMII Fiber mode.
> 
> Signed-off-by: Matheos Worku <matheos.worku@sun.com>

Applied, with some coding style cleanups.
