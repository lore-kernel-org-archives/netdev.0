From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
Date: Wed, 21 Aug 2013 01:12:01 +0200
Message-ID: <20130820231201.GA31154@electric-eye.fr.zoreil.com>
References: <1376730002-9235-1-git-send-email-lekensteyn@gmail.com>
 <20130820.151036.1067735437451172978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38029 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948Ab3HTXMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 19:12:14 -0400
Content-Disposition: inline
In-Reply-To: <20130820.151036.1067735437451172978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> > Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> 
> Can I get some reviews and Ack's for this?

It's more consistent with the {get / set}_wol parts of the driver and
it's done in a way both Hayes and myself agreed on during the previous
messages.

So you can consider it:

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
