From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Sun, 15 Jul 2007 17:36:02 -0700 (PDT)
Message-ID: <20070715.173602.104033132.davem@davemloft.net>
References: <1184431535.14136.62.camel@localhost.localdomain>
	<20070714.204951.112046547.davem@davemloft.net>
	<469A2D59.6080209@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ranko@spidernet.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@kernel-bugs.osdl.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759413AbXGPAf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 20:35:59 -0400
In-Reply-To: <469A2D59.6080209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 15 Jul 2007 16:21:13 +0200

> This one is a regression in 2.6.22, so the patch should also go
> in -stable IMO.

I have it queued up for submission to -stable.
