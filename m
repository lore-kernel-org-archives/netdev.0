From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] Coverity patches for drivers/isdn
Date: Tue, 14 Oct 2014 15:05:57 -0400 (EDT)
Message-ID: <20141014.150557.2056089957840978733.davem@davemloft.net>
References: <cover.1413021630.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, hjlipp@web.de,
	isdn@linux-pingi.de, isdn4linux@listserv.isdn4linux.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbaJNTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:06:00 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)

> Here's a series of patches for the ISDN CAPI subsystem and the
> Gigaset ISDN driver.
> Patches 1 to 7 are specific fixes for Coverity warnings.
> Patches 8 to 11 fix related problems with the handling of invalid
> CAPI command codes I noticed while working on this.
> Patch 12 fixes an unrelated problem I noticed during the subsequent
> regression tests.
> It would be great if these could still be merged.

Series applied, thanks.
