From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bas_gigaset: correctly allocate USB interrupt transfer
 buffer
Date: Wed, 18 Mar 2009 23:44:37 -0700 (PDT)
Message-ID: <20090318.234437.86482822.davem@davemloft.net>
References: <20090318-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kawk@users.sourceforge.net, hjlipp@web.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52243
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754246AbZCSGou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:44:50 -0400
In-Reply-To: <20090318-patch-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Wed, 18 Mar 2009 16:58:50 +0100 (CET)

> bas_gigaset: correctly allocate USB interrupt transfer buffer
> 
> Every USB transfer buffer has to be allocated individually by kmalloc.
> 
> Impact: bugfix, no functional change
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Tested-by: Kolja Waschk <kawk@users.sourceforge.net>

Patch applied to net-2.6, thanks.
