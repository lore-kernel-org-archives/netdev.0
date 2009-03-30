From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 0/3] Trivial doc fixes for RCU (v3)
Date: Mon, 30 Mar 2009 11:02:51 +0200
Message-ID: <20090330085302.19172.22808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40319 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757599AbZC3JCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 05:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial RCU documentation fixes.

It seems that majordomo eate my mail to the netdev list, as stgit
didn't quote the email adresses correctly.  As names which have
characters such as "." in them must be fully surrounded by
double quotes when they appear in email headers.  For this
to work with .gitconfig mail aliases the quotes needs to
be escaped.

So let hope the third time is the last, for these trivial patches.
---

Jesper Dangaard Brouer (3):
      Doc: Fix spelling in RCU/rculist_nulls.txt.
      Doc: Fix wrong API example usage of call_rcu().
      Doc: Fix missing whitespaces in RCU documentation.


 Documentation/RCU/listRCU.txt       |    6 +++---
 Documentation/RCU/rcu.txt           |    2 +-
 Documentation/RCU/rculist_nulls.txt |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
