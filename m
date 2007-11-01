From: Simon Horman <horms@verge.net.au>
Subject: [patch 0/2] ipvs: avoid overcommit on the standby, take II
Date: Thu, 01 Nov 2007 18:28:18 +0900
Message-ID: <20071101092818.083169402@vergenet.net>
Cc: Wensong Zhang <wensong@linux-vs.org>,
	"Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Julian Anastasov <ja@ssi.bg>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	"David S. Miller" <davem@davemloft.net>
To: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:38621 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755098AbXKAJcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 05:32:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two related patches from Rumen G. Bogdanovski
to help prevent overcommit on the standby.

After sending the last patchset I discovered scripts/checkpatch.pl and
found that it didn't like quite a few things. I've fixed those problems
and here is the result.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

