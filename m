From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: NIU in-driver TX backlog management.
Date: Sun, 22 Jun 2008 16:16:54 -0700 (PDT)
Message-ID: <20080622.161654.88409561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com,
	matheos.worku@sun.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753421AbYFVXQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 19:16:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is equivalent to the set of patches I recently posted
two versions of for tg3, except for NIU this time.

See the TG3 patch postings for the rationale behind this
and where this is going.
