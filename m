From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Thu, 24 Sep 2015 00:44:43 +0200
Message-ID: <20150923224443.GB7833@electric-eye.fr.zoreil.com>
References: <1442844109.7367.5.camel@infradead.org>
 <20150922.164522.1769837358584981735.davem@davemloft.net>
 <1442996049.36485.32.camel@infradead.org>
 <20150923.105812.149257816141624869.davem@davemloft.net>
 <1443037530.74600.29.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48191 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbbIWWrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:47:33 -0400
Content-Disposition: inline
In-Reply-To: <1443037530.74600.29.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> I can shuffle things around if you disagree, but assuming Francois
> concurs I'd suggest merging patches 1-6 (or just pulling from
> git://git.infradead.org/users/dwmw2/linux-8139cp.git fixes-only)
> and then I'll resubmit the last patch some time later, after you
> next pull net into net-next.

No objection but I do not really trust whatever review I do this late.

Did you try #5 with the DMA allocation debug code enabled ?

-- 
Ueimor
