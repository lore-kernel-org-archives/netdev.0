From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 26 May 2009 15:14:10 -0700 (PDT)
Message-ID: <20090526.151410.109935435.davem@davemloft.net>
References: <20090525.225503.173348268.davem@davemloft.net>
	<200905262022.24593.mb@bu3sch.de>
	<20090526.145211.37114439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, michael.riepe@googlemail.com,
	romieu@fr.zoreil.com, rsantos@grupopie.com, m.bueker@berlin.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755080AbZEZWOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 18:14:11 -0400
In-Reply-To: <20090526.145211.37114439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 26 May 2009 14:52:11 -0700 (PDT)

> From: Michael Buesch <mb@bu3sch.de>
> Date: Tue, 26 May 2009 20:22:23 +0200
> 
>> I didn't notice a CC:stable.
>> I think this should also go to stable.
>> Does somebody take care?
> 
> I'll queue it up.

Actually, this patch doesn't even remotely come close to applying
to 2.6.29.4

So if someone wants this in -stable, they need to respin this against
that tree and (if wanted) 2.6.27.x -stable as well.
