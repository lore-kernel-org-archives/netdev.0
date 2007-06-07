From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 0/2] NetLabel cleanups
Date: Thu, 07 Jun 2007 11:32:26 -0400
Message-ID: <20070607153226.524778346@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:33208 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760090AbXFGPgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two straight-forward, smallish patches against David's net-2.6 tree which fix
some kernel unaligned access errors/messages and remove some redundant code.
I've tested this patchset on both x86 and ia64 platforms and have not seen
any regressions.

I'm not sure about my timing, but if it is too late for 2.6.22 please consider
these for 2.6.23.

Thanks.

-- 
paul moore
linux security @ hp
