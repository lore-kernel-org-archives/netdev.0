From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6 net-2.6.25] IPv6 RAW: Compact the API for the kernel
Date: Mon, 19 Nov 2007 22:36:10 -0800 (PST)
Message-ID: <20071119.223610.130444916.davem@davemloft.net>
References: <473DA465.6020301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753731AbXKTGgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:36:10 -0500
In-Reply-To: <473DA465.6020301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 16 Nov 2007 17:08:37 +0300

> Same as in the previous patch for ipv4, compact the
> API and hide hash table and rwlock inside the raw.c
> file.
> 
> Plus fix some "bad" places from checkpatch.pl point 
> of view (assignments inside if()).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
