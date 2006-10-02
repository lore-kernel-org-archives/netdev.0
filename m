From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 1/5] remove TxStartThresh and RxEarlyThresh
Date: Mon, 2 Oct 2006 15:10:55 +0800
Message-ID: <018401c6e5f1$e76590f0$4964a8c0@icplus.com.tw>
References: <1159813431.2576.0.camel@localhost.localdomain><20061001235312.aa2c6d17.akpm@osdl.org> <ada3ba7xkvx.fsf@cisco.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr16.hinet.net ([168.95.4.116]:5774 "EHLO msr16.hinet.net")
	by vger.kernel.org with ESMTP id S932710AbWJBHLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 03:11:15 -0400
To: "Andrew Morton" <akpm@osdl.org>,
	"Roland Dreier" <rdreier@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, I had typed wrong word.

It is because patent issue.

Thnaks.
----- Original Message ----- 
From: "Roland Dreier" <rdreier@cisco.com>
To: "Andrew Morton" <akpm@osdl.org>
Cc: "Jesse Huang" <jesse@icplus.com.tw>; <linux-kernel@vger.kernel.org>;
<netdev@vger.kernel.org>; <jgarzik@pobox.com>
Sent: Monday, October 02, 2006 3:00 PM
Subject: Re: [PATCH 1/5] remove TxStartThresh and RxEarlyThresh


> > For pattern issue need to remove TxStartThresh and RxEarlyThresh.

 > Please describe this issue more completely.
 >
 > What are the implications of simply removing this feature?  Presumably
that
 > code was there for a reason..

Actually I think this patch needs to be handled delicately -- because
based on earlier emails from Jesse
(http://www.mail-archive.com/netdev@vger.kernel.org/msg22254.html),
I am pretty sure that "pattern" is a typo for "patent".  So I guess
the question is what exactly the patent covers and what the
implications of having the current kernel code are.

 - R.


