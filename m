From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/sb1250: remove CONFIG_SIBYTE_STANDALONE
Date: Tue, 27 Apr 2010 15:54:06 -0700 (PDT)
Message-ID: <20100427.155406.215554679.davem@davemloft.net>
References: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
	<1272229348-16140-2-git-send-email-sebastian@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43139
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755088Ab0D0WyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:54:01 -0400
In-Reply-To: <1272229348-16140-2-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Sun, 25 Apr 2010 23:02:28 +0200

> CONFIG_SIBYTE_STANDALONE is gone since v2.6.31-rc1 ("MIPS: Sibyte:
> Remove standalone kernel support")
> This is a missing piece.
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

Applied to net-next-2.6, thanks.
