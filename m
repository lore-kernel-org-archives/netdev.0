From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding...
Date: Thu, 03 Mar 2011 12:43:10 -0800
Message-ID: <13010.1299184990@death>
References: <20110303114539.GB5146@hmsreliant.think-freely.org> <20110303160404.GO11864@gospo.rdu.redhat.com> <6286.1299173065@death> <20110303.123032.15242274.davem@davemloft.net>
Cc: andy@greyhouse.net, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:58047 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756708Ab1CCUnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:43:14 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p23KedIn022778
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 13:40:39 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p23KhDKj126360
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 13:43:13 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p23Kemg5015647
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 13:40:49 -0700
In-reply-to: <20110303.123032.15242274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Thu, 03 Mar 2011 09:24:25 -0800
>
>> 	My main problem keeping up at the moment is another demand on my
>> time that should run its course in a couple of weeks.  My time for
>> community activity is somewhat limited until then.
>
>Someone needs to exist who can keep things going when you are too
>busy.  Unless you're like me and never take a day off, you need
>at least one co-maintainer if your subsystem has lots of daily
>activity as bonding now does.

	Agreed.  If Andy is amenable, we can make it official:

diff --git a/MAINTAINERS b/MAINTAINERS
index 0d83e58..6402703 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1467,6 +1467,7 @@ F:	include/net/bluetooth/
 
 BONDING DRIVER
 M:	Jay Vosburgh <fubar@us.ibm.com>
+M:	Andy Gospodarek <andy@greyhouse.net>
 L:	netdev@vger.kernel.org
 W:	http://sourceforge.net/projects/bonding/
 S:	Supported


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
