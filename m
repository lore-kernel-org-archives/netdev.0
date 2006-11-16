From: David Miller <davem@davemloft.net>
Subject: net-2.6.20 rebased
Date: Thu, 16 Nov 2006 05:58:40 -0500 (EST)
Message-ID: <20061116.055840.78704296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:4078 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1423798AbWKPK6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 05:58:40 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just rebased net-2.6.20 at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.20.git

Al Viro has been going crazy with endianness and checksum type
sparse annotations, which brings the patch count up to 171.
Not bad for how long the net-2.6.20 tree has been open :-)

I'm moving over the weekend, but never fear I've already made sure I
can "ping" my new house and thus the internet is working and waiting
for me when I get there.  I expect a total email down time of a day or
two, I should be close to %100 next Monday or Tuesday.  In the
interim, while my machines are moving with me, I have vger.kernel.org
handling my email.  So if something strange happens to my email,
that's why.

The only changes I didn't get to yet are ipv6 patches from Ville
Nuorvala.  I'll try to get those in tomorrow, but I can't guarentee
that.  If not, I'll get to it next week.

Feel free to still bomb me with patches though :-)
