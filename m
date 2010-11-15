From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] offloading: Support multiple vlan tags in GSO.
Date: Mon, 15 Nov 2010 09:23:43 -0800 (PST)
Message-ID: <20101115.092343.48497196.davem@davemloft.net>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
	<1288390495-28923-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932303Ab0KORXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:23:18 -0500
In-Reply-To: <1288390495-28923-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 29 Oct 2010 15:14:54 -0700

> We assume that hardware TSO can't support multiple levels of vlan tags
> but we allow it to be done.  Therefore, enable GSO to parse these tags
> so we can fallback to software.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
