From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88x6xxx: Zero statistics counters
Date: Tue, 23 Jun 2015 06:37:37 -0700 (PDT)
Message-ID: <20150623.063737.1237579188603074208.davem@davemloft.net>
References: <1434828689-11804-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, cory.tusar@pid1solutions.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbbFWNZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:25:48 -0400
In-Reply-To: <1434828689-11804-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 20 Jun 2015 21:31:29 +0200

> Zero the statistics counters when setting up the global
> registers. Otherwise the counters will remain from the last boot if
> the power has not been removed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
