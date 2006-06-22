From: paul.moore@hp.com
Subject: [RFC 0/8] Minor update to allow a "sane review"
Date: Thu, 22 Jun 2006 18:49:11 -0400
Message-ID: <20060622224910.885573000@flek.zko.hp.com>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:41433 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1030434AbWFVWyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 18:54:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a minor update to the patch set I set yesterday (June 21st), the
changes include minor Makefile fixes and a patch/file reordering as suggested
by David Miller.  In addition, there are some minor changes to fix problems
brought about by different build combinations.

I have not yet made the shift to the generic NETLINK mechanism, but
considering the review problems due to the poor patch/file ordering I thought
it best to re-issue the patch set with that problem fixed so people would be
able to review the patch further.

--
paul moore
linux security @ hp
