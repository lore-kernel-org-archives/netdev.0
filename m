From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH torvalds-2.6] cdc_ether: fix autosuspend for mbm devices
Date: Tue, 27 Apr 2010 17:07:57 -0700 (PDT)
Message-ID: <20100427.170757.146099597.davem@davemloft.net>
References: <201004261214.13836.torgny.johansson@ericsson.com>
	<201004261230.21713.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torgny.johansson@ericsson.com, netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50475
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754335Ab0D1AHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:07:51 -0400
In-Reply-To: <201004261230.21713.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Mon, 26 Apr 2010 12:30:21 +0200

>> Also, if you like this patch, is it possible to get it included in a minor release of 2.6.33 (e.g. 2.6.33.3) as a bugfix?
> 
> Up to David.

I'll apply to net-2.6 and queue up for -stable, thanks.
