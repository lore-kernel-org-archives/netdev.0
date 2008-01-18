From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Thu, 17 Jan 2008 16:26:45 -0800
Message-ID: <24607.1200616005@death>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org> <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl> <20080114144754.29a448ad.akpm@linux-foundation.org> <16796.1200351673@death> <20080117154243.9ee4265c.akpm@linux-foundation.org>
Cc: olel@ans.pl, davem@davemloft.net, jeff@garzik.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43885 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757344AbYARA0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:26:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0Qmnh027658
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:26:48 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0Qmo9249710
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:26:48 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0QluU025092
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:26:48 -0500
In-reply-to: <20080117154243.9ee4265c.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andrew Morton <akpm@linux-foundation.org> wrote:
[...]
>Can we get this bug fixed please?  Today?  It has been known about for more
>than two months.

	I just reposted the complete fix; it's #1 of the series of 7.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
