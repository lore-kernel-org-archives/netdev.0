From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27/28-stable] bas_gigaset: correctly allocate USB
 interrupt transfer buffer
Date: Mon, 23 Mar 2009 15:00:05 -0700 (PDT)
Message-ID: <20090323.150005.113220590.davem@davemloft.net>
References: <20090323-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, kawk@users.sourceforge.net, hjlipp@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbZCWWAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:00:18 -0400
In-Reply-To: <20090323-patch-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Mon, 23 Mar 2009 22:47:06 +0100 (CET)

> the following patch backports the Gigaset driver bugfix merged for
> 2.6.29 as commit 170ebf85160dd128e1c4206cc197cce7d1424705 to both
> v2.6.27.x and v2.6.28.x. I would appreciate to see it included in
> your stable series.

If you ask me I can and will do it during my networking patch
-stable submission.
