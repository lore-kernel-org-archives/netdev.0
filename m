From: David Miller <davem@davemloft.net>
Subject: GIT: net-next-2.6 is now active...
Date: Mon, 08 Nov 2010 14:05:30 -0800 (PST)
Message-ID: <20101108.140530.200355693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33455
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755457Ab0KHWFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 17:05:05 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4B34D24C08A
	for <netdev@vger.kernel.org>; Mon,  8 Nov 2010 14:05:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've started the net-next-2.6 tree going, and I'll push
out the initial set of changes (the ones that actually
compile, grumble...) shortly.

I could have started things up last week, but with kernel
summit and LPC there just wasn't much time or justification.

Probably the most interesting thing in this initial set are
the AF_UNIX poll optimizations from Eric Dumazet.
