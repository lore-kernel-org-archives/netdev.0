From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] unify netlink kernel socket recognition
Date: Wed, 10 Oct 2007 21:14:39 -0700 (PDT)
Message-ID: <20071010.211439.55505234.davem@davemloft.net>
References: <20071005144743.GA7105@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org,
	containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751057AbXJKEOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:14:36 -0400
In-Reply-To: <20071005144743.GA7105@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 5 Oct 2007 18:47:43 +0400

> There are currently two ways to determine whether the netlink socket is a
> kernel one or a user one. This patch creates a single inline call for
> this purpose and unifies all the calls in the af_netlink.c
> 
> No similar calls are found outside af_netlink.c.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied.
