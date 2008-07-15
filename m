From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7 net-next-2.6] tipc: Remove unneeded parameter to
 tipc_createport_raw()
Date: Mon, 14 Jul 2008 22:42:27 -0700 (PDT)
Message-ID: <20080714.224227.233597351.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-2-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754486AbYGOFm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:42:26 -0400
In-Reply-To: <1215725171-10094-2-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:05 -0400

> This patch eliminates an unneeded parameter when creating a low-level
> TIPC port object.  Instead of returning both the pointer to the port
> structure and the port's reference ID, it now returns only the pointer
> since the port structure contains the reference ID as one of its fields.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
