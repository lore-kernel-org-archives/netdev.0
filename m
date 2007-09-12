From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] Small cleanup for 2.6.24 and a git tree test
Date: Wed, 12 Sep 2007 15:29:31 -0400
Message-ID: <20070912192305.18318.11911.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:50040 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755080AbXILTaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 15:30:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cleanup patch is pretty trivial and is explained in it's own email, but
essentially it is just moving similar code into a new function and then
modifying the original functions to call the newly created function.

The new and exciting thing is that I actually decided I should probably know
how to do more than just clone git trees, which means you can get this patch
by pulling from the brand spankin' new labeled networking git tree.  The tree
looks okay to me but it's possible I munged something, if that is the case let
me know and I'll try to fix it ... I'd like to get this working at some point.

 * git://git.infradead.org/users/pcmoore/lblnet-2.6

Thanks.

-- 
paul moore
linux security @ hp
