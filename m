From: David Miller <davem@davemloft.net>
Subject: Re: [MACVLAN]: Update Kconfig to refer to iproute
Date: Tue, 26 Feb 2008 17:52:15 -0800 (PST)
Message-ID: <20080226.175215.129133312.davem@davemloft.net>
References: <47C2D5F7.4070503@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763090AbYB0Bva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 20:51:30 -0500
In-Reply-To: <47C2D5F7.4070503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 25 Feb 2008 15:51:35 +0100

> [MACVLAN]: Update Kconfig to refer to iproute
> 
> Since the macvlan release I had at least 5 users asking how to configure
> it since the old userspace tool doesn't work with the version in the
> kernel. Add a pointer to the Kconfig help.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
