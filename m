From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] staging: netlogic: Fix build error due to
 missed API change
Date: Sun, 10 Jan 2016 22:07:23 -0500 (EST)
Message-ID: <20160110.220723.750201203154546164.davem@davemloft.net>
References: <1452470263-25993-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758080AbcAKDHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:07:25 -0500
In-Reply-To: <1452470263-25993-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 11 Jan 2016 00:57:43 +0100

> Fix a number of build errors due to moving the phy_map and centralizing
> interrupt allocation.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
