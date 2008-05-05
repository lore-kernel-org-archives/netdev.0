From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9 net-next-2.6] [TIPC]: Cosmetic cleanup of system &
 debug output declarations
Date: Mon, 05 May 2008 01:23:46 -0700 (PDT)
Message-ID: <20080505.012346.214023312.davem@davemloft.net>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
	<1209412126-2109-8-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753657AbYEEIXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:23:46 -0400
In-Reply-To: <1209412126-2109-8-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 28 Apr 2008 15:48:44 -0400

> This patch contains changes to make TIPC's system & debug
> message declarations more readable.  Declarations have been
> regrouped and recommented to make it easier to understand
> what output is generated in both standard and debugging modes.
> In addition, oversize lines have been fixed to respect the
> 80 character upper bound used in the kernel.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
