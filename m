From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6 net-2.6.25][RAW] Introduce raw_hashinfo structure
Date: Mon, 19 Nov 2007 22:36:59 -0800 (PST)
Message-ID: <20071119.223659.40918942.davem@davemloft.net>
References: <473DA54F.6040801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753975AbXKTGg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:36:59 -0500
In-Reply-To: <473DA54F.6040801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 16 Nov 2007 17:12:31 +0300

> The ipv4/raw.c and ipv6/raw.c contain many common code (most
> of which is proc interface) which can be consolidated.
> 
> Most of the places to consolidate deal with the raw sockets
> hashtable, so introduce a struct raw_hashinfo which describes 
> the raw sockets hash.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
