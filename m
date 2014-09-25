From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: RE: [PATCH 1/3] defxx: Correct DEFEA's ESIC port I/O accesses
Date: Thu, 25 Sep 2014 12:14:19 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1409251212370.6148@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org> <alpine.LFD.2.11.1409251028070.6148@eddie.linux-mips.org> <063D6719AE5E284EB5DD2968C1650D6D1749D806@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:51672 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaIYLOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 07:14:22 -0400
Received: from localhost.localdomain ([127.0.0.1]:35857 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27008971AbaIYLOTzGPMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 13:14:19 +0200
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1749D806@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014, David Laight wrote:

> > Reverse the order of arguments to `outb', data to write comes first.
> 
> How long has this actually been wrong?
> It is just worth deleting the driver?

 What's the value in deleting the driver?

  Maciej
