From: David Miller <davem@davemloft.net>
Subject: reminder, 2.6.18 window...
Date: Tue, 23 May 2006 18:22:17 -0700 (PDT)
Message-ID: <20060523.182217.59656237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36000
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932107AbWEXBWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 21:22:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.sfo1.dsl.speakeasy.net (Postfix) with ESMTP id 540BFAE43EA
	for <netdev@vger.kernel.org>; Tue, 23 May 2006 18:22:17 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some time in the next few weeks, it is likely that the 2.6.18
merge window will open up shortly after a 2.6.17 release.

So if you have major 2.6.18 submissions planned for the networking,
you need to start thinking about getting it to me now.

There is a 2.6.18 tree up at:

master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.18.git

All it has right now is the I/O AT stuff at the moment, and I plan to
put Stephen Hemminger's LLC multicast/datagram changes in there as
well.

Thanks.
