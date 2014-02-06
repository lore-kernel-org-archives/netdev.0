From: David Howells <dhowells@redhat.com>
Subject: Should I use the pernet stuff for rxrpc sysctls
Date: Thu, 06 Feb 2014 23:08:16 +0000
Message-ID: <25347.1391728096@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568AbaBFXIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 18:08:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

I would like to add some sysctls for RxRPC to configure timeouts and
suchlike.  Should I use the pernet stuff to make it namespaceable?  I notice
that most net/ dirs don't use this yet.

David
