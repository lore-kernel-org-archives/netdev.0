From: James Cloos <cloos@jhcloos.com>
Subject: /proc/net/tcp6 missing entries
Date: Sat, 30 Sep 2006 08:04:03 -0400
Message-ID: <m3zmchblx1.fsf@lugabout.jhcloos.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ore.jhcloos.com ([64.240.156.239]:18955 "EHLO ore.jhcloos.com")
	by vger.kernel.org with ESMTP id S1750910AbWI3MGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 08:06:01 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Has anything changed recently that would affect /ptoc/net/tcp6?

None of the outgoing tcp/ip6 sockets show up there on my laptop.

I'm currently at Linus' tree as of f164c42161d21368d9cd4d6d6efc158baa2618db
with the then-upstream branch of libata (since merged into Linus' tree) and
Ingo's 18-rt3 patch.

I'd prefer not to waste time bisecting if it is already know and fixed....

-JimC
-- 
James Cloos <cloos@jhcloos.com>         OpenPGP: 0xED7DAEA6
