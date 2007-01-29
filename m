From: David Miller <davem@davemloft.net>
Subject: net-2.6.21 GIT tree
Date: Sun, 28 Jan 2007 16:54:41 -0800 (PST)
Message-ID: <20070128.165441.125893049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932991AbXA2Ayn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:54:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E51A6AE4162
	for <netdev@vger.kernel.org>; Sun, 28 Jan 2007 16:54:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just cut it at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.21.git

Feel free to send me feature patches for consideration.

I'll probably toss things like Baruch's latest SACK fixes in
there so they can cook for a while and then perhaps after some
time we'll backport them into whatever -stable branch is active
at the time.

Thanks.
