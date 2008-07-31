From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/11] nsc-ircc: default to dongle type 9 on IBM
 hardware
Date: Wed, 30 Jul 2008 17:00:57 -0700 (PDT)
Message-ID: <20080730.170057.47288436.davem@davemloft.net>
References: <200807301937.m6UJbfsn012452@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mjg59@srcf.ucam.org,
	ben.collins@canonical.com, samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53328
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753038AbYGaAA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:00:57 -0400
In-Reply-To: <200807301937.m6UJbfsn012452@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:40 -0700

> This is necessary to set the dongle type on the nsc driver in order to get
> it to work correctly.  Thinkpads all appear to use dongle type 9.  This
> patch defaults nsc devices with an IBM PnP descriptor to use type 9.
> 
> Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>
> Signed-off-by: Ben Collins <ben.collins@canonical.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Ugly, but what can we do? :-)

Applied, thanks!
