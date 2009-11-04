From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: cleanup include/net
Date: Wed, 04 Nov 2009 05:07:46 -0800 (PST)
Message-ID: <20091104.050746.126372138.davem@davemloft.net>
References: <4AF0031B.4060708@gmail.com>
	<20091103.024424.146854177.davem@davemloft.net>
	<4AF02F6B.6040405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57201
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756081AbZKDNHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:07:21 -0500
In-Reply-To: <4AF02F6B.6040405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Nov 2009 14:26:03 +0100

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

Applied.
