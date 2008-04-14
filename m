From: David Miller <davem@davemloft.net>
Subject: GIT tree status
Date: Mon, 14 Apr 2008 02:41:33 -0700 (PDT)
Message-ID: <20080414.024133.61963719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751423AbYDNJlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 05:41:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3C300C8CA9B
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 02:41:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All bug fixes I am aware of are in net-2.6 and a pull request has been
sent to Linus.  Very likely he will release 2.6.25 for real early this
week.  Therefore this is likely to be the last major batch of net
fixes before 2.6.25-final.

Large chunks of the backlog got added to net-2.6.26, and I also pulled
net-2.6 into net-2.6.26 in order to resolve various conflicts.

Please double-check my merge conflict resolution work on the
net-2.6.26 tree!  Especially wireless and netdev folks.

I still have some bits in my backlog for net-2.6.26 and a few bug
reports to look into.

Thanks everyone.
