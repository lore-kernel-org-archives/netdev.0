From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: route.c: Change checks against 0xffffffff to
 ipv4_is_lbcast()
Date: Mon, 18 Oct 2010 07:23:59 -0700 (PDT)
Message-ID: <20101018.072359.104044884.davem@davemloft.net>
References: <1287364282.2320.20.camel@morgan.silverblock.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: awalls@md.metrocast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755845Ab0JROXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 10:23:36 -0400
In-Reply-To: <1287364282.2320.20.camel@morgan.silverblock.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Walls <awalls@md.metrocast.net>
Date: Sun, 17 Oct 2010 21:11:22 -0400

> 
> Change a few checks against the hardcoded broadcast address,
> 0xffffffff, to ipv4_is_lbcast().  Remove some existing checks
> using ipv4_is_lbcast() that are now obviously superfluous.
> 
> Signed-off-by: Andy Walls <awalls@md.metrocast.net>

Applied.
