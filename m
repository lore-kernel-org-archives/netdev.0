From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Adding ND to bonding?
Date: Mon, 03 Jun 2013 13:53:06 -0700
Message-ID: <10725.1370292786@death.nxdomain>
References: <30520718.20.1370268797936.JavaMail.root@zimbra>
Cc: netdev <netdev@vger.kernel.org>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45465 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753Ab3FCUxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 16:53:10 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 3 Jun 2013 16:53:09 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 9ADDC38C8042
	for <netdev@vger.kernel.org>; Mon,  3 Jun 2013 16:53:07 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r53Kr706277682
	for <netdev@vger.kernel.org>; Mon, 3 Jun 2013 16:53:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r53Kr7X9009279
	for <netdev@vger.kernel.org>; Mon, 3 Jun 2013 17:53:07 -0300
In-reply-to: <30520718.20.1370268797936.JavaMail.root@zimbra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roy Sigurd Karlsbakk <roy@karlsbakk.net> wrote:
[...]
>We're hoping one day we can move to an IPv6-only network (with some
>gatewaying to IPv4 land), and I wonder if it would be hard to add
>Neighbor Discovery Protocol to bonding as to allow for bonding on
>ipv6. I'm not much of a kernel coder, but for what I could see, it looks
>doable.

	I haven't tested it lately, but I'm reasonably sure that ND runs
over bonding.  Is there something specific you have in mind here?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
