From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: remove firmware for RTL8169D PHY
Date: Sun, 01 Nov 2009 22:47:11 -0800 (PST)
Message-ID: <20091101.224711.230845851.davem@davemloft.net>
References: <1257115687.3136.337.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, edward_hsu@realtek.com.tw,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753713AbZKBGqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 01:46:47 -0500
In-Reply-To: <1257115687.3136.337.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 01 Nov 2009 22:48:07 +0000

> The recently added support for RTL8169D chips included some machine
> code without accompanying source code.  Replace this with use of the
> firmware loader.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> Here's my attempt at the driver change.  I leave it to you to work out
> licencing of the firmware blob.

I'm not even looking at this patch until you do some research
and substantiate your claims about what this thing is doing.
