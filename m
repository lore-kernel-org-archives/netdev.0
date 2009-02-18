From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/43] drivers/net/sfc: fix sparse warnings: Should it
 be static?
Date: Tue, 17 Feb 2009 17:39:57 -0800 (PST)
Message-ID: <20090217.173957.140516246.davem@davemloft.net>
References: <20090214214111.24377.87888.stgit@vmbox.hanneseder.net>
	<20090216003718.GN15266@solarflare.com>
	<154e089b0902160138n255616a0xb963dfd990d912b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47214
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756489AbZBRBkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:40:13 -0500
In-Reply-To: <154e089b0902160138n255616a0xb963dfd990d912b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 16 Feb 2009 10:38:26 +0100

> On Mon, Feb 16, 2009 at 1:37 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > This is wrong.  The entire file is conditional on CONFIG_SFC_MTD.
> 
> Even better than. It's actually not wrong, just done twice, so we can
> omit it, thank you Ben. I'll send an update.

Ok, I'll skip over this patch.
