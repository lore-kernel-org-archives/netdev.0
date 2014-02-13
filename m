From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Wed, 12 Feb 2014 19:25:20 -0500 (EST)
Message-ID: <20140212.192520.955911778570827692.davem@davemloft.net>
References: <1392226067-21736-1-git-send-email-fw@strlen.de>
	<20140213002413.GK11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaBMAZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:25:22 -0500
In-Reply-To: <20140213002413.GK11150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 13 Feb 2014 01:24:13 +0100

> I actually expect arp answers for ip addresses bound to loopback even from an
> interface without ip address, if we strictly conform to the week end host
> model in linux.

Agreed.
