From: holger@eitzenberger.org
Subject: [patch 0/7] [RFC] bonding updates to net-next-2.6
Date: Tue, 09 Dec 2008 21:07:50 +0100
Message-ID: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54560 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbYLIUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:14:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

these are some patches against the bonding code in net-next-2.6.
I hope you find them usefull.

As you requested previously I tried to make bond_start_xmit() use a
function table instead of the switch statement, but with some unexpected
results which I'm currently analyzing.  I therefore leave it as-is.

Thanks for your previous feedback.

 /holger


