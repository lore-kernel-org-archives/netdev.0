From: David Miller <davem@davemloft.net>
Subject: git tree plans...
Date: Tue, 04 Mar 2008 17:30:53 -0800 (PST)
Message-ID: <20080304.173053.20837154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752708AbYCEBa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 20:30:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8432CC8C23C
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2008 17:30:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are my immediate plans for the two networking GIT trees:

1) net-2.6

   Nothing special planned, I will keep it stable and
   not pull in linux-2.6's master branch unless something
   potentially creating merge issues arises.

2) net-2.6.26

   Once Linus takes the current changes in net-2.6, I plan
   to pull net-2.6's master into net-2.6.26 in order to
   resolve the wireless and potentially other merge problems

Take care.
