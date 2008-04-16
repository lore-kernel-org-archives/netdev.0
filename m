From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 net-2.6.26] [TIPC]: Optimized initialization of
 TIPC reference table
Date: Tue, 15 Apr 2008 19:00:27 -0700 (PDT)
Message-ID: <20080415.190027.67014303.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752717AbYDPCAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:00:31 -0400
In-Reply-To: <1208288637-15304-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:52 -0400

> This patch optimizes the initialization phase of TIPC's reference
> table, so that it initializes table entries on an "as needed" basis.
> (Previously, all entries of the table were initialized, regardless
> of whether they actually ended up being used.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Dropping because it depends upon patch #1 which I've rejected.
