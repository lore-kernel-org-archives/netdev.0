From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] ipv4: minor cleanup in net/ipv4/tcp_ipv4.c.
Date: Mon, 16 Jun 2008 17:07:39 -0700 (PDT)
Message-ID: <20080616.170739.154935390.davem@davemloft.net>
References: <eb3ff54b0806160207r473055c3y329b6ec66b902572@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751050AbYFQAHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:07:39 -0400
In-Reply-To: <eb3ff54b0806160207r473055c3y329b6ec66b902572@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Mon, 16 Jun 2008 12:07:31 +0300

> 1) Remove ICMP_MIN_LENGTH, as it is unused.
> 
> 2) Remove unneeded tcp_v4_send_check() declaration.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied to net-2.6, thanks Rami.
