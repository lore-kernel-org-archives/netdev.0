From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: DSA: Marvell mv88e6171 switch driver
Date: Sat, 13 Sep 2014 17:27:10 -0400 (EDT)
Message-ID: <20140913.172710.328059942751512747.davem@davemloft.net>
References: <1410559124-10495-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, leitec@staticky.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaIMV1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:27:12 -0400
In-Reply-To: <1410559124-10495-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 12 Sep 2014 23:58:44 +0200

> This is the Marvell driver with some cleanups by Claudio Leite
> and myself.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, I took care of the tag_protocol conflict.
