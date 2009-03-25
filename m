From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ax88796: Add method to take MAC from platform data
Date: Tue, 24 Mar 2009 23:32:11 -0700 (PDT)
Message-ID: <20090324.233211.100636173.davem@davemloft.net>
References: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
	<1237738361-10184-2-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@simtec.co.uk, matthias.j.meier@gmx.net
To: daniel@caiaq.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754630AbZCYGcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:32:24 -0400
In-Reply-To: <1237738361-10184-2-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@caiaq.de>
Date: Sun, 22 Mar 2009 17:12:41 +0100

> Implement a way to provide the MAC address for ax88796 devices from
> their platform data. Boards might decide to set the address
> programmatically, taken from boot tags or other sources.
> 
> Signed-off-by: Daniel Mack <daniel@caiaq.de>

Also applied, thanks.
