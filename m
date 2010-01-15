From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Fri, 15 Jan 2010 00:26:34 -0800 (PST)
Message-ID: <20100115.002634.247919259.davem@davemloft.net>
References: <4B4F132B.7020001@gmail.com>
	<20100114.165142.163322281.davem@davemloft.net>
	<4B502644.4070000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752283Ab0AOI0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:26:24 -0500
In-Reply-To: <4B502644.4070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Jan 2010 09:24:36 +0100

> Well, its a good idea but it has drawbacks, for example if your eth0 device
> has 64 tx queues. Parsing tc output can be... interesting :)

Tool problem :-)
