From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix broken ip= parsing
Date: Sat, 29 Dec 2007 18:59:48 -0800 (PST)
Message-ID: <20071229.185948.13302114.davem@davemloft.net>
References: <20071229170849.C2E68C2EEE@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35904
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbXL3C7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 21:59:55 -0500
In-Reply-To: <20071229170849.C2E68C2EEE@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Sat, 29 Dec 2007 18:08:49 +0100 (CET)

> Commit a6c05c3d064dbb83be88cba3189beb5db9d2dfc3 breaks ip= parsing
> completly, because ic_enable is never set. The patch below puts
> back the way ic_enable was set before.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

I already have this exact patch in my net-2.6 tree from Simon.
Thanks.
