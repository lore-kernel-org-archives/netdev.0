From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Wed, 12 Nov 2008 00:41:49 -0800 (PST)
Message-ID: <20081112.004149.183320510.davem@davemloft.net>
References: <B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
	<20081111.141600.225275728.davem@davemloft.net>
	<98649BFE-855E-429E-AB30-BAFED77A5FF1@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Doug.Leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752965AbYKLIlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 03:41:50 -0500
In-Reply-To: <98649BFE-855E-429E-AB30-BAFED77A5FF1@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <Doug.Leith@nuim.ie>
Date: Wed, 12 Nov 2008 08:36:30 +0000

> Patch attached.

I wanted you to make a full resubmission with the patch fixed up.

Otherwise I don't have your commit message, and it isn't all collected
properly when your patch is logged to:

	http://patchwork.ozlabs.org/project/netdev/list

When you are requested to fixup a patch or make some modification,
always, and I do mean always, make a fresh new submission (changelog
and all) unless you are told otherwise.
