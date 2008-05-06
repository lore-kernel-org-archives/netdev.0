From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Mon, 05 May 2008 23:58:58 -0700 (PDT)
Message-ID: <20080505.235858.105477615.davem@davemloft.net>
References: <1210005880.5716.4.camel@Linux.home>
	<20080505.123703.257416714.davem@davemloft.net>
	<481FFBFE.4020900@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbYEFG66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 02:58:58 -0400
In-Reply-To: <481FFBFE.4020900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 06 May 2008 10:34:38 +0400

> David Miller wrote:
> > I think I should revert your change.
> 
> Agree. Sorry, for the confusion.

No worries, thanks for confirming.  I'll revert the change
right now.
