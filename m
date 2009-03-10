From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: RDS: no freely available protocol specification?
Date: Tue, 10 Mar 2009 23:07:45 +0100
Message-ID: <7i63ihm3pq.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Grover <andy.grover@oracle.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:59765 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbZCJWqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 18:46:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

I am a little worried about the Reliable Datagram Sockets (RDS), which are
currently in the process of being merged into the kernel.  I've checked the
latest Interned-Drafts index, I've tried searching the web, and I cannot
find a freely available protocol specification.  (I've been unable to check
the documentation section of the oss.oracle.com site, which requires
a password with no way to register visible to my tired eyes.)

I am wondering whether we wish to encourage the use of proprietary
(undocumented) protocols, and I wish that the kernel crowd should really
try to put some pressure on the Oracle guys to get the RDS protocol spec
published as an RFC, or at the very least submitted as an Internet Draft,
before it is released as part of the Linux kernel.

                                        Juliusz Chroboczek
