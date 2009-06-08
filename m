From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis190: fix for x86_64 (bug 11509)
Date: Mon, 08 Jun 2009 00:10:07 -0700 (PDT)
Message-ID: <20090608.001007.189583451.davem@davemloft.net>
References: <20090608054758.GA21975@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: birrachiara@tin.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750875AbZFHHKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:10:07 -0400
In-Reply-To: <20090608054758.GA21975@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Riccardo Ghetta <birrachiara@tin.it>
Date: Mon, 8 Jun 2009 07:47:58 +0200

> Corrected dma sync handling on small packets. Should fix 
> http://bugzilla.kernel.org/show_bug.cgi?id=11509
> Note:
> While this bug was reported only on x86_64, it could have affected
> any architecture.
> 
> Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>

Applied to net-next-2.6
