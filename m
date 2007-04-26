From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] bridge: missing rtnl
Date: Wed, 25 Apr 2007 22:08:59 -0700 (PDT)
Message-ID: <20070425.220859.56861479.davem@davemloft.net>
References: <20070425234737.727790594@linux-foundation.org>
	<20070425234950.847694502@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754703AbXDZFIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 01:08:51 -0400
In-Reply-To: <20070425234950.847694502@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 25 Apr 2007 16:47:41 -0700

> Writing to /sys/class/net/brX/bridge/stp_state causes a warning because
> RTNL is not held when call br_stp_if.c
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
