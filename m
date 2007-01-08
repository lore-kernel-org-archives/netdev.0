From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.20-rc4
Date: Sun, 07 Jan 2007 19:53:26 -0800 (PST)
Message-ID: <20070107.195326.25157009.davem@davemloft.net>
References: <1168219153.12025.17.camel@violet>
	<20070107.172411.132927338.davem@davemloft.net>
	<1168220681.12025.26.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030484AbXAHDx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jan 2007 22:53:27 -0500
To: marcel@holtmann.org
In-Reply-To: <1168220681.12025.26.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 08 Jan 2007 02:44:41 +0100

> it is way too late and you are absolutely right. However since the
> current code doesn't produce a compiler warning of an uninitialized
> variable, I prefer to not go with a "int err = 0" to make this work.
> 
> I rebuild the tree with the correct fix in it and it is now ready to be
> pulled.

That version of the fix is much better, pulled and pushed back out
to kernel.org, thanks.
