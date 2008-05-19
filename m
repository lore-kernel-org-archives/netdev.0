From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5 net-next-2.6] [TIPC]: Add support for customized
 subscription endianness
Date: Mon, 19 May 2008 13:30:28 -0700 (PDT)
Message-ID: <20080519.133028.150257160.davem@davemloft.net>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
	<1210702665-5012-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757659AbYESUad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:30:33 -0400
In-Reply-To: <1210702665-5012-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 13 May 2008 14:17:42 -0400

> This patch enables TIPC's topology server code to do customized
> endianness conversions on a per-subscription basis.  (This
> capability is needed to support the upcoming consolidation of
> subscriber and subscription object references.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
