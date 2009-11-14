From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: add the missing netlink get_xstats_size callback
Date: Fri, 13 Nov 2009 19:58:24 -0800 (PST)
Message-ID: <20091113.195824.48418352.davem@davemloft.net>
References: <4AFC2AED.1090607@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757717AbZKND6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:58:08 -0500
In-Reply-To: <4AFC2AED.1090607@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 12 Nov 2009 16:34:05 +0100

> This patch adds the missing "get_xstats_size" callback for the
> netlink interface, which is required if "fill_xstats" is used,
> as pointed out by Patrick McHardy.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
