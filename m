From: David Miller <davem@davemloft.net>
Subject: Re: zaurus: Add ID for C-750/C-760/C-860/SL-C3000 PDA in MDLM mode
Date: Tue, 21 Feb 2012 15:29:05 -0500 (EST)
Message-ID: <20120221.152905.2176553875935353729.davem@davemloft.net>
References: <20120221032813.GA14228@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab2BUU3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:29:16 -0500
In-Reply-To: <20120221032813.GA14228@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 20 Feb 2012 22:28:13 -0500

> In 16adf5d07987d93675945f3cecf0e33706566005 I removed an over-broad
> alias that caused zaurus.ko to bind to unrelated devices.
> I had a report that at least one valid case no longer auto-loads because of this.
> This patch adds an ID for that case.
> 
> Reported-by: Raphael Wimmer <raphael.wimmer@ur.de>
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied.
