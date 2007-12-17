From: David Miller <davem@davemloft.net>
Subject: net-2.6.25 rebased...
Date: Sun, 16 Dec 2007 16:21:01 -0800 (PST)
Message-ID: <20071216.162101.209866976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755029AbXLQAVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 19:21:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I needed to rebase for two reasons:

1) Ilpo asked me to revert a lot of TCP stuff and the
   easiest way to do that was during a rebase.

2) Patrick McHardy needs some of the pending net-2.6
   bug fixes in there in order to send me patches
   for some netfilter compat stuff.

It's all there in the usual spot:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git

I'm still doing build tests with various configurations on my
Niagara-2 box.

Let me know if I screwed up anything, thanks!
