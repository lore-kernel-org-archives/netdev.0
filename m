From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] sctp: add transport state in
 /proc/net/sctp/remaddr
Date: Thu, 30 Oct 2014 19:40:37 -0400 (EDT)
Message-ID: <20141030.194037.985317768601307127.davem@davemloft.net>
References: <1414661356-17255-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: michele@acksyn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161211AbaJ3Xkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:40:39 -0400
In-Reply-To: <1414661356-17255-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Baldessari <michele@acksyn.org>
Date: Thu, 30 Oct 2014 10:29:15 +0100

> It is often quite helpful to be able to know the state of a transport
> outside of the application itself (for troubleshooting purposes or for
> monitoring purposes). Add it under /proc/net/sctp/remaddr.
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>

Applied.
