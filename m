From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 net-next-2.6] tipc: Optimize pointer dereferencing
 when receiving stream data
Date: Mon, 14 Jul 2008 22:42:59 -0700 (PDT)
Message-ID: <20080714.224259.173593521.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754702AbYGOFm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:42:58 -0400
In-Reply-To: <1215725171-10094-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:06 -0400

> This patch eliminates an unnecessary pointer dereference when
> accessing a stream-based socket's receive queue.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
