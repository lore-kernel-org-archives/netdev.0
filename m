From: David Miller <davem@davemloft.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Tue, 01 Dec 2009 15:54:20 -0800 (PST)
Message-ID: <20091201.155420.192663257.davem@davemloft.net>
References: <4B088600.8090209@trash.net>
	<767BAF49E93AFB4B815B11325788A8ED4B1FDC@L01SLCXDB03.calltower.com>
	<4B154337.8060702@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@bigfootnetworks.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753329AbZLAXyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 18:54:14 -0500
In-Reply-To: <4B154337.8060702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 01 Dec 2009 17:24:23 +0100

> Dave, attached is the patch again with a proper changelog.

Applied to net-2.6, thanks a lot everyone.

I'll queue this up for -stable as well.
