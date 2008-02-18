From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tcp_v4_send_synack() comment
Date: Sun, 17 Feb 2008 22:29:38 -0800 (PST)
Message-ID: <20080217.222938.184483277.davem@davemloft.net>
References: <47B3937F.6010106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: katterjohn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752222AbYBRG3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 01:29:01 -0500
In-Reply-To: <47B3937F.6010106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kris Katterjohn <katterjohn@gmail.com>
Date: Wed, 13 Feb 2008 19:03:59 -0600

> Hey everyone,
> 
> I've attached a patch that fixes the comment above tcp_v4_send_synack() 
> in ipv4/tcp_ipv4.c.
> 
> Signed-off-by: Kris Katterjohn <katterjohn@gmail.com>

Applied, thanks.

Please "-p1" root your patches in the future.
