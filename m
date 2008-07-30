From: David Miller <davem@davemloft.net>
Subject: Re: Fix error checking in niu driver
Date: Tue, 29 Jul 2008 23:59:32 -0700 (PDT)
Message-ID: <20080729.235932.35123634.davem@davemloft.net>
References: <jefxps8qm1.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: schwab@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751233AbYG3G7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 02:59:35 -0400
In-Reply-To: <jefxps8qm1.fsf@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schwab <schwab@suse.de>
Date: Tue, 29 Jul 2008 20:58:14 +0200

> The callers of niu_ethflow_to_class expect zero as error, but it returns
> -1 instead.
> 
> Signed-off-by: Andreas Schwab <schwab@suse.de>

Applied, thanks Andreas.
