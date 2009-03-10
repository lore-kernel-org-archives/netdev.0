From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gigaset: Kconfig cleanup
Date: Tue, 10 Mar 2009 05:25:13 -0700 (PDT)
Message-ID: <20090310.052513.106958818.davem@davemloft.net>
References: <20090307-patch-00.tilman@imap.cc>
	<20090307-patch-02.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pebolle@tiscali.nl, hjlipp@web.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754787AbZCJMZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:25:27 -0400
In-Reply-To: <20090307-patch-02.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat,  7 Mar 2009 23:11:02 +0100 (CET)

> Streamline dependencies and remove some obsolete or redundant comments
> in the Gigaset ISDN driver's Kconfig file. In particular, remove the
> strong warning against the GIGASET_UNDOCREQ option, as in seven years
> of existence, the code in question has never been reported to cause
> any harm.
> 
> Impact: Kconfig cleanup, no functional change
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Also applied, thanks.
