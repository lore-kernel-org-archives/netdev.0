From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [Patch 1/1] dccp: dead code elimination
Date: Fri, 10 Dec 2010 12:59:30 +0100
Message-ID: <1291982371-5666-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <4D01FBBE.2030705@cn.fujitsu.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34210 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755512Ab0LJL7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 06:59:39 -0500
In-Reply-To: <4D01FBBE.2030705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

can you please consider the attached patch - it removes indeed dead code.
I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Shan,
I have edited the commit message (s/marcos/macros/). In future, please
can you cc: your patches to netdev@vger also. Thank you.

Gerrit
