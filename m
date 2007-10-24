From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Tue, 23 Oct 2007 18:00:01 -0700
Message-ID: <7923.1193187601@death>
References: <1192667871139-git-send-email-fubar@us.ibm.com> <1192667875793-git-send-email-fubar@us.ibm.com> <471E94F3.5050407@garzik.org>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44278 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbXJXBAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 21:00:03 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9O103lF011858
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 21:00:03 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9O103Al117172
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 19:00:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9O102N5015446
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 19:00:02 -0600
In-reply-to: <471E94F3.5050407@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:

>applied patches 1-6

	Thanks.

>However, two issues:
>
>1) Credit.  Did Andy write these, as the Signed-off-by lines indicate? 

	Andy did some of it and I did some of it, so I presume that dual
Signed-off-by is correct (vs. one Signed-off and one Acked).

>2) vague subject line. [...]

	Sorry about that; will keep it in mind next time.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
