From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [TIPC]: Fixed erroneous introduction of
 for_each_netdev
Date: Wed, 23 May 2007 15:12:02 -0700 (PDT)
Message-ID: <20070523.151202.95506681.davem@davemloft.net>
References: <1>
	<11792748743802-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756283AbXEWWMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 18:12:00 -0400
In-Reply-To: <11792748743802-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Paul Maloy <jon.maloy@ericsson.com>
Date: Tue, 15 May 2007 20:21:14 -0400

> 
> Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>

Patch applied, thanks Jon.

I specifically had the developer of that change audit for this exact
kind of bug, my apologies that this one case still slipped through :-/
