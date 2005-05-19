From: Andrew Morton <akpm@osdl.org>
Subject: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Wed, 18 May 2005 20:24:58 -0700
Message-ID: <20050518202458.55a63d37.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is the second report of this happening.


Begin forwarded message:

Date: Wed, 18 May 2005 23:10:49 -0400
From: Nick Orlov <bugfixer@list.ru>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org
Subject: 2.6.12-rc4-mm[12] - ULOG problem


ipt_ULOG fails to load starting from 2.6.12-rc4-mm1 with the following
error message:


FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/kernel/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory

rc3-mm3 works fine.

Unfortunately, I wont have time to do a binary search till the weekend,
but I hope you'll point suspicious patch(es) without it.

Any additional info available by request.

-- 
With best wishes,
	Nick Orlov.
