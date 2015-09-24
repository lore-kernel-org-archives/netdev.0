From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Thu, 24 Sep 2015 09:25:25 +0200
Message-ID: <20150924072525.GA14697@electric-eye.fr.zoreil.com>
References: <1443078810.74600.45.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49032 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbbIXH2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 03:28:21 -0400
Content-Disposition: inline
In-Reply-To: <1443078810.74600.45.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> Haha, right. Want me to roll that in and resubmit that patch?

Yes. It's your series and you are ultimately testing it anyway.

-- 
Ueimor
