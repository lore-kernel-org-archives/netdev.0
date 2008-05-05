From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9 net-next-2.6] [TIPC]: Exclude debug-only print
 buffer code when not debugging
Date: Mon, 05 May 2008 01:24:14 -0700 (PDT)
Message-ID: <20080505.012414.05592453.davem@davemloft.net>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
	<1209412126-2109-9-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752355AbYEEIYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:24:14 -0400
In-Reply-To: <1209412126-2109-9-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 28 Apr 2008 15:48:45 -0400

> This patch modifies TIPC to only exclude debug-related print buffer
> routines when debugging capabilities are not required.  It also
> fixes up some related #defines that exceed 80 characters.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
