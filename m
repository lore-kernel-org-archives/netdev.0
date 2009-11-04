From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: cleanup include/linux
Date: Wed, 04 Nov 2009 09:51:10 -0800 (PST)
Message-ID: <20091104.095110.105275928.davem@davemloft.net>
References: <4AF02F6B.6040405@gmail.com>
	<20091104.050746.126372138.davem@davemloft.net>
	<4AF1BE5B.2080208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44650
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756190AbZKDRup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:50:45 -0500
In-Reply-To: <4AF1BE5B.2080208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 18:48:11 +0100

> [PATCH net-next-2.6] net: cleanup include/linux
> 
> This cleanup patch puts struct/union/enum opening braces,
> in first line to ease grep games.
> 
> struct something
> {
> 
> becomes :
> 
> struct something {
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
