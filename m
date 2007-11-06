From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: problems with ib-bonding of 2.6.24-rc1
Date: Mon, 05 Nov 2007 17:05:54 -0800
Message-ID: <20510.1194311154@death>
References: <472DF022.3000604@voltaire.com> <472EFB28.9090000@gmail.com>
Cc: Moni Shoua <monis@voltaire.com>, netdev@vger.kernel.org
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58462 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754521AbXKFBF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 20:05:57 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA615uMJ001214
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 20:05:56 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA615ujZ493778
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 20:05:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA615uoC016877
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 20:05:56 -0500
In-reply-to: <472EFB28.9090000@gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moni Shoua <monisonlists@gmail.com> wrote:

>Basically, what I see is that after a while commands like ifconfig or ip stucks.
>I only use sysfs  to configure bonding (which also stucks after a while).

	I've fooled with setting various things in bonding in the
current linux-2.6 git kernel, and I'm not seeing the failure you
describe.  Can you provide some step by step instructions, including the
type of system, bonding mode, options, number and type of slaves, etc,
to induce the failure?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
