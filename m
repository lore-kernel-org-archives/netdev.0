From: Andrew Walrond <andrew@walrond.org>
Subject: iputils git access broken?
Date: Wed, 6 Apr 2011 21:32:51 +0000
Message-ID: <20110406213251.GA1398@localhost.heresymail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pitney-fabs.co.uk ([87.106.140.52]:47406 "EHLO
	gimli.pitney-fabs.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985Ab1DFU6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:58:39 -0400
Received: from [92.17.190.168] (helo=localhost.heresymail.org)
	by gimli.pitney-fabs.co.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <walrond.andrew@gimli.pitney-fabs.co.uk>)
	id 1Q7ZQN-0003lC-J1
	for netdev@vger.kernel.org; Wed, 06 Apr 2011 20:34:01 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can't seem to clone the repo, although I can see source on gitweb.

$ git clone git://git.linux-ipv6.org/gitroot/iputils.git
Cloning into iputils...
git.linux-ipv6.org[0: 203.178.142.218]: errno=Connection refused
git.linux-ipv6.org[0: 2001:200:0:1c01:20f:1fff:fe67:32e9]: errno=Network is unreachable
fatal: unable to connect a socket (Network is unreachable)

Is something amiss?

Andrew Walrond
(cc me please; I'm not subscribed)
