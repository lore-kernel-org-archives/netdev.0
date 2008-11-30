From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gigaset: remove unnecessary poll method
Date: Sat, 29 Nov 2008 21:39:03 -0800 (PST)
Message-ID: <20081129.213903.155135966.davem@davemloft.net>
References: <1227876791.git.tilman@imap.cc>
	<9b6d85e917139005e83f6b93460d71c4220cc880.1227876791.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbYK3FjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 00:39:04 -0500
In-Reply-To: <9b6d85e917139005e83f6b93460d71c4220cc880.1227876791.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat, 29 Nov 2008 23:41:07 +0100 (CET)

> The N_GIGASET_M101 line discipline implemented by the ser_gigaset
> driver does not transfer any data from/to userspace through the
> tty interface. Therefore a poll method is not needed.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied to net-next-2.6
