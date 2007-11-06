From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 06 Nov 2007 14:49:44 -0800
Message-ID: <25756.1194389384@death>
References: <200710301948.MAA04351@tardy.cup.hp.com> <5242.1193777750@death> <4727D583.90807@hp.com> <4730DF40.6090606@hp.com>
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:56710 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205AbXKFWts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 17:49:48 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA6MnlTv030060
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:49:47 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA6Mnlfv486018
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:49:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA6Mnll8003275
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:49:47 -0500
In-reply-to: <4730DF40.6090606@hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Rick Jones <rick.jones2@hp.com> wrote:

>So, where do you and I stand wrt the proposed changes to bonding.txt?  Are
>we at an impass?

	Nope, I'm doing a doc update next to incorporate several things,
the reordering stuff included (which I plan to change to describe the
levels of badness, as it were).  Needed to fix a couple "no workee"
things first.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
