From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gigaset: get rid of info() and warn() macros
Date: Sat, 29 Nov 2008 21:39:12 -0800 (PST)
Message-ID: <20081129.213912.116149226.davem@davemloft.net>
References: <1227876791.git.tilman@imap.cc>
	<ba0787515baca3b67eca4bc526a3a7b2db70bbb9.1227876791.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751217AbYK3FjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 00:39:12 -0500
In-Reply-To: <ba0787515baca3b67eca4bc526a3a7b2db70bbb9.1227876791.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat, 29 Nov 2008 23:41:07 +0100 (CET)

> Join the move away from the obsolete info() macro, opencoding the
> remaining uses. While we're at it, also get rid of the warn() macro
> by promoting the three remaining uses to err().
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Also applied to net-next-2.6

Thanks
