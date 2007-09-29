From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] PHYLIB: Spinlock fixes for softirqs
Date: Sat, 29 Sep 2007 01:31:52 -0400
Message-ID: <46FDE348.3010801@pobox.com>
References: <Pine.LNX.4.64N.0709181532190.9650@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47970 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943AbXI2Fb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:31:58 -0400
In-Reply-To: <Pine.LNX.4.64N.0709181532190.9650@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

doesn't Andrew have a version of these patches that move the useful 
patch text into the area where it will get copied into the permanent 
kernel changelog?

also, your PHYLIB patches give no notion at all of proper patch order.


