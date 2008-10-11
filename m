From: David Miller <davem@davemloft.net>
Subject: net GIT trees being rebased
Date: Sat, 11 Oct 2008 11:15:08 -0700 (PDT)
Message-ID: <20081011.111508.62618824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932714AbYJKSPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 14:15:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2BCEEC8C18A
	for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 11:15:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just FYI, I'm blowing away all of the networking GIT trees
(net-2.6 and net-next-2.6) now that Linus has pulled all of
the 2.6.28 merge window bits in.

I will create a fresh clone of Linus's tree as:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

and we will put bug fixes into there until 2.6.28 is released.

I will not create a net-next-2.6 tree for about 2 weeks.  It should
happen about when the merge window closes.

