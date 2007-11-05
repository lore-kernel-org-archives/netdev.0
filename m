From: horms@vergenet.net
Subject: [patch 0/2] ipvs: avoid overcommit on the standby, take III
Date: Mon, 05 Nov 2007 12:08:51 +0900
Message-ID: <20071105030851.615630269@vergenet.net>
Cc: "Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>,
	"David S. Miller" <davem@davemloft.net>
To: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47131 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbXKEDNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 22:13:39 -0500
From: Simon Horman <horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two related patches from Rumen G. Bogdanovski
to help prevent overcommit on the standby.


On the last two attempts I have managed to send somewhat bogus patches.
So I started from scratch. I tool the original patches, fixed
up what scripts/checkpatch.pl didn't like, then compared the output
to my previous attempt, which happily showed the bogus bits
that I know about have been fixed.

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

