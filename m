From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Workaround to fix a bug in Rx Completion
 processing.
Date: Wed, 30 Sep 2009 21:58:30 -0700 (PDT)
Message-ID: <20090930.215830.261415227.davem@davemloft.net>
References: <20091001040247.GA28228@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750940AbZJAE6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 00:58:10 -0400
In-Reply-To: <20091001040247.GA28228@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 1 Oct 2009 09:33:22 +0530

> vtp bit in RX completion descriptor could be wrongly set in
> some skews of BladEngine.  Ignore this  bit if vtm is not set.
> Resending because the previous patch was against net-next tree.
> This patch is against the net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, thanks.
