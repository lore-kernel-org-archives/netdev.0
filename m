From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9 net-next-2.6] [TIPC]: Fix null pointer dereference
 in debug code
Date: Mon, 05 May 2008 01:22:01 -0700 (PDT)
Message-ID: <20080505.012201.100178481.davem@davemloft.net>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
	<1209412126-2109-5-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752723AbYEEIWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:22:01 -0400
In-Reply-To: <1209412126-2109-5-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 28 Apr 2008 15:48:41 -0400

> This patch eliminates an obsolete use of the DBG_OUTPUT print
> buffer which could lead to a null pointer crash in tipc_printf()
> if TIPC's debugging capabilities are configured.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
