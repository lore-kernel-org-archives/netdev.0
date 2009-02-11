From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fore200: fix oops on failed firmware load
Date: Tue, 10 Feb 2009 17:19:28 -0800 (PST)
Message-ID: <20090210.171928.157511700.davem@davemloft.net>
References: <Pine.SOC.4.64.0902101701420.11180@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55122
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756905AbZBKBTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 20:19:34 -0500
In-Reply-To: <Pine.SOC.4.64.0902101701420.11180@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 10 Feb 2009 19:39:24 +0200 (EET)

> Fore 200 ATM driver fails to handle request_firmware failures and oopses 
> when no firmware file was found. Fix it by checking for the right return 
> values and propaganting the return value up.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

Applied, thank you.
